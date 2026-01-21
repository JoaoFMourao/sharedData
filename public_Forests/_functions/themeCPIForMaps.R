
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILD GRAPHIC SPECIFIC FUNCTION
# AUTHOR: TEAM EFFORT
#
# > NOTES
# 1: -





# BASIC GGPLOT MAP CONSTRUCTION THEME ---------------------------------------------------------------------------------------------------------------
# NOTES ON GGPLOT:
# ggplot can only do one hole per poly. To plot polygons with multiple holes, e.g. deter clouds, place factor(hole) inside fill and col arguments
# and determine colours for both inside and outside of holes. See code on deter clouds maps for example.

ThemeCPIForMaps <- function(base_size = 10, font = "Calibri") {
  
  
  theme(
    
    # AXIS
    axis.title.x = element_blank(),  # element_blank() removes feature
    axis.text.x  = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    
    
    
    
    # BACKGROUND
    panel.background = element_rect(fill = "white", colour = "white", color = "white"),
    
    
    
    
    # LEGEND
    legend.position      = "bottom",
    legend.box           = "horizontal",
    legend.title         = element_blank(),
    legend.background    = element_rect(fill = "transparent", colour = NA),
    legend.key           = element_rect(fill = "transparent", colour = NA , size = 5),
    legend.margin        = margin(t = 0, unit='cm'), 
    legend.text	         = element_text(size = 10),
    legend.justification = c(0.5, 0),
    legend.spacing.x     = unit(0.2, 'cm'),
    
    
    
    
    # TITLE
    plot.title    = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 9, hjust = 0.5))
  
}

# 
print( "*** ATTENTION! - ALWAYS RESPECT THE ORDER IN LEVELS(FACTOR(COLUMN_NAME)) WHEN SETTING COLORS AND LEGENDS MANUALLY! ***")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------