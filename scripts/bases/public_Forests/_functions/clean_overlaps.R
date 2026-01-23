# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# This is an R function named "clean_imaflora" that processes and manipulates 
# spatial data stored in a database. The function takes four arguments:
  
# mun_code - a character string representing the municipality code.

# db - a database object that contains the spatial data.

# cls - a character string representing the name of the column in the database 
#containing the categorical data that will be used to order and filter the data.

# order - a vector of character strings representing the order in which the 
#categorical data in cls will be processed.

#The function uses the "dplyr" and "sf" (simple features) libraries to manipulate 
#the data. The data is first filtered and selected, then grouped by the 
#categorical data in cls, and filtered again based on the order specified in order. 
#The st_difference function is used to compute the difference between two 
#spatial objects and the st_make_valid function is used to clean up any invalid 
#geometries. The st_buffer function is used to add a buffer around the geometries.

#The processed data is then returned with an added muni_code column 
#containing the mun_code argument.

clean_overlaps <- function(mun_code, db, cls, order) {
  
  print('This function requires the following packages: "sf", "tidyverse", "rlang", "furrr"')
  
  # Get unique values in cls column
  hey <- db %>%
    select(cls) %>% # select the cls column
    st_drop_geometry() %>% # remove the geometry column from the data
    distinct() %>% # remove any duplicate values
    as.vector.data.frame(mode = "list") %>% # convert the data frame to a list
    unname # remove the names of the list elements
  
  vect <- unlist(hey)
  for (h in 1:length(vect)) {
    if (is.na(vect[h])==T) {
      vect[h] <- 0
      
    }
    
    
  }
  
    
    
   
  
  # Get the intersection of order and vect
  order <- intersect(order,vect)
  
  # Principal loop starting with the first category
  for (i in 1:length(order)) {
    
    # Get the data grouped by cls and filtered by the current order value
    now <- db %>%
      group_by_at(cls) %>% # group the data by the cls column
      filter((!!sym(cls)) == order[i]) %>% # filter by the current order value
      summarise() %>% # summarise the grouped data
      st_make_valid() %>% 
      st_buffer(0)

    # If i is greater than 1, perform difference and cleaning operations
    if(i > 1) {
      
      # Get the data grouped by cls and filtered by previous order value
      prior <- final %>% 
        select(geometry) %>% 
        summarise() # summarise the grouped data
        
          
          
      # Compute the difference between now and prior, clean up any invalid geometries, add a buffer
      now <- now %>% 
        st_difference(prior) %>% # compute the difference
        st_make_valid() %>% # make sure the geometries are valid
        st_buffer(0) %>% # add a buffer of size 0
        select(cls) %>%  # select the cls column
        group_by_at(cls) %>% # group the data by the cls column
        summarise() %>% # summarise the grouped data
        st_make_valid() %>% # make sure the geometries are valid
        st_buffer(0) # add a buffer of size 0
        
      
      
      # Bind the now data to final
      final <- final %>% 
        rbind(now)
    
    } else {
      # If i is equal to 1, set final to the filtered and summarised data
      final <- db %>%
        group_by_at(cls) %>% # group the data by the cls column
        filter((!!sym(cls)) == order[1]) %>% # filter by the first order value
        summarise() # summarise the grouped data
        
    }
  }
  
  # Add mun_code column to the final data
  final <- final %>% 
    mutate(muni_code = mun_code) %>% # add the mun_code column with the specified value
    st_make_valid() %>% 
    st_buffer(0)
    
  # Return the final data
  return(final)
} 

#END OF SCRIPT-----------------------------------------
       