
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: FUNCTION TO INTERSECT POLYGONS THAT OVERLAP
# AUTHOR: TEAM EFFORT
#
# > EDIT DETAILS
# BY: JOAO VIEIRA
# ON: JUN/10/19
#
# > NOTES
# 1: -





# INTERSECTION ---------------------------------------------------------------------------------------------------------------------------------------

IntersectPolygonsThatOverlap <- function(arg.layer1, arg.layer2) {
  
  # OPTIMIZES INTERSECTION BY TESTING FOR POLYGON OVERLAP FIRST
  #
  # ARGS
  #   arg.layer1: SpatialPolygons*, first  layer to be intersected
  #   arg.layer2: SpatialPolygons*, second layer to be intersected
  #
  # RETURNS
  #   SpatialPolygons of overlap area between argument layers
  
  
  # ERROR CHECK
  stopifnot(identicalCRS(arg.layer1, arg.layer2))
  
  
  
  # OVERLAP TEST
  temp1 <- gIntersects(arg.layer1, arg.layer2, byid = T, returnDense = F)  # creates a list of the length of arg.layer1; if element index is NULL,   >
  temp2 <- gIntersects(arg.layer2, arg.layer1, byid = T, returnDense = F)  # polygon does not intersect any arg.layer2 polygons
  
  
  
  # INTERSECTED POLYGON SELECTION
  for (list.element in 1:length(temp1)) {                                  # flags polygons in arg.layer1 to keep/drop based on overlap test
    if (temp1[list.element] != "NULL") {
      temp1[list.element] <- "KEEP"
    } else {
      temp1[list.element] <- "DROP"
    }
  }
  
  for (list.element in 1:length(temp2)) {                                  # flags polygons in arg.layer2 to keep/drop based on overlap test
    if (temp2[list.element] != "NULL") {
      temp2[list.element] <- "KEEP"
    } else {
      temp2[list.element] <- "DROP"
    }
  }
  
  intersect.matrix1 <- as.matrix(temp1)
  intersect.matrix2 <- as.matrix(temp2)
  
  layer1.subsetByIntersect <- arg.layer1[which(intersect.matrix1 == "KEEP"), ]
  layer2.subsetByIntersect <- arg.layer2[which(intersect.matrix2 == "KEEP"), ]
  
  
  
  # INTERSECTION
  intersection <- gIntersection(spgeom1 = layer1.subsetByIntersect,
                                spgeom2 = layer2.subsetByIntersect,
                                byid    = T)
  
  
  
  # RETURN
  return(intersection)
}




# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------