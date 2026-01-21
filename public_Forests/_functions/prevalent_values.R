# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: IDENTIFY THE MOST COMMOM VALUES WITHIN A VARIABLE
# AUTHOR: JOAO F. MOURAO
#
#
# > NOTES
# 1: THIS IS USEFULL FOR TWO MAIN PROPOSALS, IDENTIFY IF NA VALUES
#ARE IDENTIFIED BY OTHER KIND OF CHARACTHER SUCH AS ""
#
# 2: THIS FUNCTION COULD BE REPLACED BY A COMMAND EQUIVALENT TO TABLE VARIALBE,SORT IN STATA
#
#3: THIS FUNCTION CAN ALSO HELP IDENTIFY THE ID VARIABLE OF DATA FRAME. FOR THAT VARIABLE, ALL 
# VALUES SHOULD APPEAR ONLY ONCE. FOR INSTANCE, IF YOU GOT A DATA BASE WITH EACH MUNICIPALITY POPULATION IN 2010
# THE ID VARIABLE SHOULD IS THE MUNICIPAL CODE, WITH EACH VALUE APPEARING ONLY ONCE.
#
# 3.1: FIRST CAVEAT: IF EACH MUNICIPALITY HAS A DIFFERENT POPULATION, THEN THE EACH POPULATIONAL VARIABLE WILL ONLY
# BE COMPOSED BY UNIQUE VALUES. HOWEVER, ONE SHOULD NOT 
#
# 3.2: SOME DATA BASES ARE GOING TO NEED TO HAVE MORE THAN ONE ID_VARIABLE TO IDENTIFY THE POPULACION. FOR INSTANCE, IF YOU HAVE
# THE POPULATION OF EACH MUNICIPALITY FROM 2010 TO 2020, PROBABLY, YOU WILL NEED TO VARIABLES TO UNIQUELY IDENTIFY AN OBSERVATION
# THE MUNICIPALITY CODE AND YEAR. IN THIS CASE, JUST PROVIDE A LIST AS THE COL ARGUMENT SUCH AS: COL = C("muni_code","year")
#
#
# 4: Often, you are want to apply this function to the complete database, for that reason, somenthing like
# "pmap(list(colnames(DT)), ~ values(DT,..1))" will do the trick

prevalent_values <- function(DT, #the data base beeing analyzed
                             col #the collumn or list of collums you want to look at as a string, sucha as "muni_code", 
                             #or c("muni_code","year")
                             ) {
  
  print(col) #I link to print the collumns name
  
  if("sf" %in% class(DT)){
    DT <- DT %>% as_tibble()
    
  }
  
  
  out <- DT %>%
    #group the data
    group_by_at(
      vars(
        all_of(
          col
          )
        )
      )%>%
    #identify the number of observations 
    dplyr::summarize(n = n()) %>%
    #ungroup the data
    ungroup() %>%
    #calculate the total number of observations
    mutate(tot = sum(n),
           #than the share of this total each group represents
           percent = n/tot) %>%
    #order than from the most frequent, to the less frequent values
    arrange(-n) %>%
    
    #some modern versions of the tidyverse demmans a conclusion "as_tibble".
    as_tibble()
  
  out
  
}