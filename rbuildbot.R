library(rjson)
library(RCurl)

URL <- "http://buildbot.buildbot.net"


bb_setUrl <- function(url)
{
  URL <<- url
}


bb_getBuilders <- function(url=URL)
{
  url <- paste( url, "/json/builders", sep="" )
  txt = getURL(url, write = basicTextGatherer())
  a = fromJSON(txt)
  names(a)
}

bb_getSlaves <- function(url=URL)
{
  url <- paste( url, "/json/slaves", sep="" )
  txt = getURL(url, write = basicTextGatherer())
  a = fromJSON(txt)
  names(a)
}

bb_getBuildsJSON <- function(url=URL, builders=NA, buildNr = -1)
{
  if( is.na(builders[1]) )
  {
    builders <- bb_getBuilders(url)
    builders <- builders[1]
  }
  l <- list()
  for( b in builders )
  {
    for( i in buildNr)
    {
      u <- paste(url, "/json/builders/", b, "/builds/", i, sep="")
      txt <- getURL(u, write = basicTextGatherer())
      l[[length(l)+1]] <- fromJSON(txt)
    }
  }
  l
}

bb_getBuilds <- function(url = URL, builders=NA, buildNr = -1, buildbotVer='')
{
  v_builderName = c()
  v_slave = c()
  v_result = c()
  v_time_start = c()
  v_time_end = c()
  v_number = c()
  
  v_change_time = c()
  v_change_number = c()
  v_change_build_number = c()
  v_change_builder_name = c()

  builds <- bb_getBuildsJSON(url, builders, buildNr)
  for( b in builds)
  {
    v_builderName <- c(v_builderName, b$builderName)
    v_slave <- c(v_slave, b$slave)
    v_result <- c(v_result, paste(b$text, collapse=" "))
    v_time_start <- c(v_time_start, b[['times']][[1]])
    v_time_end <- c(v_time_end, b[['times']][[2]])
    v_number <- c(v_number, b$number)
    
    if( buildbotVer == '0.8.5')
    {
      for( s in b['sourceStamp'] )
      {
        for( c in s[['changes']] )
        {
          v_change_time = c(v_change_time, c$when)
          v_change_number = c(v_change_number, c$number)
          v_change_build_number = c(v_change_build_number, b$number)
          v_change_builder_name  = c(v_change_builder_name, b$builderName)
        }
      }
    }
    else
    {
        for( s in b$sourceStamps )
        {
          for( c in s$changes )
          {
            v_change_time = c(v_change_time, c$when)
            v_change_number = c(v_change_number, c$number)
            v_change_build_number = c(v_change_build_number, b$number)
            v_change_builder_name  = c(v_change_builder_name, b$builderName)
          }
        }
      }
  }
  u<-data.frame(builderName=v_builderName, number=v_number, slave=v_slave, result=v_result, time_start=v_time_start, time_end=v_time_end)
  c <- data.frame(change_number=v_change_number, change_time=v_change_time, builder_name=v_change_builder_name, build_number=v_change_build_number)
  list(u, c)
}
