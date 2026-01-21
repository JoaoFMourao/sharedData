
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





# BASIC GGPLOT GRAPHICS CONSTRUCTION THEME -----------------------------------------------------------------------------------------------------------

ThemeCPIForGraphics <- function(base_size = 10, font = "Calibri") {
  
  
  theme(

    # AXIS
    axis.line  = element_line(size = 1),
    axis.title = element_text(size = 14, face = "bold"),
    axis.text  = element_text(size = 13),
    
    
    
    
    # BACKGRUND
    panel.background    = element_rect(fill = NA, colour = NA), 
    panel.grid.major.x  = element_blank(),
    panel.grid.major.y  = element_line(colour = "#bdbdbd", linetype = "solid"), 
    
    
    
    
    # LEGEND
    legend.position      = "bottom",
    legend.box           = "horizontal",
    legend.title         = element_blank(),
    legend.background    = element_rect(fill="transparent", colour= NA),
    legend.key           = element_rect(fill="transparent", colour= NA , size=5),
    legend.margin        = margin(t = 0, unit='cm'), 
    legend.text	         = element_text(size=13.5),
    legend.justification = c(0.5, 0),
    legend.spacing.x     = unit(0.2, 'cm'),
    
    
    
    
    # TITLE
    plot.title    = element_text(size = 15, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
  
  
  
  
    # CAPTION
    plot.caption = element_text(size = 13, face = "italic", hjust = 0))
   
}

# 
print( "*** ATTENTION! - ALWAYS RESPECT THE ORDER IN LEVELS(FACTOR(COLUMN_NAME)) WHEN SETTING COLORS AND LEGENDS MANUALLY! ***")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------