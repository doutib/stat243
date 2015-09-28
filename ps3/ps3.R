library(XML)
library(stringr)

extract_URL_debate = function(year){
  #load HTML as a tree (with nodes)
  doc=htmlTreeParse("http://www.debates.org/index.php?page=debate-transcripts")
  #specify root of the tree
  root = xmlRoot(doc)
  #choose body of the doc
  body= xmlChildren(root)$body
  #find the four debates for each year. Each element of the list corresponds to a year
  debates_years=xpathApply(body, "//div/..//blockquote")
  #assign the position of the list to the year I want to extract
  code_year=(2012-year)/4+1
  #find the 4 debates for the required year
  debates_year=xpathApply(debates_years[[code_year]],"//a")
  #find description of each debate
  value=sapply(debates_year, xmlValue)
  #find the position of the n-th debate
  no_debate=grep("First",value)
  #Extract president names from value
  candidates_value=xmlValue(debates_year[[no_debate]])
  duo=str_extract(as.character(candidates_value),"[a-zA-z]+\\-[a-zA-z]+")
  candidates=str_split(duo,"-")
  #extract and return URL
  return (list(URL=xmlGetAttr(debates_year[[no_debate]],"href"),
               Names=toupper(candidates[[1]])))
}
extract_URL_debate(2012)


extract_text_debate = function (year){
  #extract url with previous function
  URL=extract_URL_debate(year)$URL
  names=extract_URL_debate(year)$Names
  #exctract html link
  doc=htmlParse(URL,isURL=T)
  #take body
  root = xmlRoot(doc)
  body= xmlChildren(root)$body
  #extract lines from body
  lines1=xpathApply(body, "//div[@id='content-sm']/p/text()", xmlValue)
  #clean data
  lines2=unlist(lines1, recursive=FALSE) #each paragraph in a line
  start=which.max(str_detect(lines2,"[A-Z]+: [A-Z][a-z]")) #start of speech
  end=which.max(str_detect(lines2,"(Â|END)"))-1 #end of it (for 2008, 2 a la suite)
  if (end==0)
    end =length(lines2)
  lines3=lines2[start:end]
  return(list(Text=paste(lines3,sep="",collapse = "\n\n"),Lines=lines3,Names=names))
}

lines=extract_text_debate(2008)$Lines
lines[1:3]
lines[(length(lines)-3):length(lines)]

#Extract sentences and words
#sentences
extract_sentences = function(year){
  text=extract_text_debate(year)$Text
  clean_text=gsub('([A-Z]+: |\\([A-Z]+\\))', '',text)
  return(str_extract_all(clean_text, "[A-Z][^.!?]+[.!?]")[[1]])
}
extract_sentences(2008)[1:10]
#words
extract_words = function(year){
  text=extract_text_debate(year)$Text
  clean_text=gsub('([A-Z]+: |\\([A-Z]+\\))', '',text)
  return(str_extract_all(clean_text, "[A-Za-z]+")[[1]])
}
extract_words(2008)

extract_speeches = function(year){
  #extract debate
  debate=extract_text_debate(year)
  lines=debate$Lines
  names=debate$Names
  #identify speakers
  speaker1=str_detect(lines,names[1])
  speaker2=str_detect(lines,names[2])
  moderator=str_detect(lines,"[A-Z]:")-speaker1-speaker2
  #I assign a unique number per speaker for each line
  state=speaker1*1+speaker2*2+moderator*3
  #now I replace the zeros folowwing the labels by the labels
  #in order to have a label for each line
  j=state[1]
  for (i in 1:length(lines)){
    if (state[i]==0)
      state[i]=j
    else
      j=state[i]
  }
  ###list of speeches labeled by name of the speakers
  #for each speaker, I merge the labels and replace
  #the names of the speakers in the text, and
  #the non verbal indicators
  list_speech=sapply(c(1,2,3),function(x) 
    gsub('([A-Z]+: |\\([A-Z]+\\) )', '',
         paste(lines[state==x],collapse=" ",sep="")))
  names(list_speech)=c(names[1],names[2],"MODERATOR")
  
  return(list_speech)
  
}
names(extract_speeches(2004))

#count words, char
extract_count_year = function(year){
  speeches= extract_speeches(year)
  #initialize data frame
  data=data.frame(date=rep(year,3),speaker=names(speeches),
                  n_words=rep(0,3),n_characters=rep(0,3),
                  average_word_length=rep(0,3))
  #count characters that are words 
  characters_words=rep(0,3)
  for (i in 1:3){
    sp=speeches[[i]]
    data[i,3]=str_count(sp,"[a-zA-Z]+")
    data[i,4]=str_length(sp)
    characters_words[i]=str_count(sp,"[a-zA-Z]")
  }
  data[,5]=(characters_words)/(data[,3]) #number of words/ number of characters without spaces
  return (data)
}
extract_count_year(1996)


#regexpr
extract_regexpr_year = function(year,regexpr){
  speeches= extract_speeches(year)
  data=data.frame(rep(year,3),names(speeches),
                  matrix(rep(0,length(regexpr)*3),nrow=3))
  names(data)=c("date","speaker",regexpr)
  for (i in 1:3){
    sp=speeches[[i]]
    for (r in 1:length(regexpr)){
      expr=regexpr[r]
      data[i,r+2]=str_count(sp,expr)
    }
  }
  return (data)
}


regexpr=c("I","we","America[n?]","democra(cy|tic)","republic",
          "Democrat(ic|[^a-zA-Z])","Republican","free(dom|[^a-zA-Z])",
          "war","God [^bB]","God [Bb]less","(Jesus|Christ|Christian)")

extract_regexpr_year(1996,regexpr)


##FOR ALL YEARS

####merge count for all years
extract_count = function(y){
  n=length(y)
  data=vector("list", n)
  for (i in 1:n){
    data[[i]]=extract_count_year(y[i])
  }
  return(Reduce(function(x, y) merge(x, y, all=TRUE), data))
}

#statistics for every person, by people
y=seq(1996,2012,by=4)
data=extract_count(y)
#average word length over all speeches
data=aggregate(average_word_length ~ speaker, data = data, mean)
#ordering the data by average word length
data[order(-data[,2]),]

###merge regexpr for all years
extract_regexpr = function(y,regexpr){
  n=length(y)
  data=vector("list", n)
  for (i in 1:n){
    data[[i]]=extract_regexpr_year(y[i],regexpr)
  }
  return(Reduce(function(x, y) merge(x, y, all=TRUE), data))
}

extract_regexpr(y,regexpr)

plot_speeches= function(year){
  r=extract_regexpr_year(year,regexpr)
  par(mar=c(8,4,3,1))
  barplot(matrix(c(as.numeric(r[1,1:length(regexpr)+2]),as.numeric(r[2,1:length(regexpr)+2]+1)),nrow=2),
          names.arg=c("I", "we", "America{,n}", "democra{cy,tic}",
                      "republic", "Democrat{,ic}", "Republican",
                      "free{,dom}", "war", "God", "God Bless",
                      "{Jesus, Christ{,ian}}"),
          las=2,main=paste(as.character(year), "Debate"),beside=T)
  legend("topright", c(as.vector(r$speaker[[1]]),as.vector(r$speaker[[2]])), pch=15, bty="n",
         col=c("black","gray"))
}
par(mfrow=c(2,2))
for (i in 1:4) plot_speeches(2012-4*(i-1))

