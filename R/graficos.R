tema_mapa <- function(){
  list(
    theme(
      panel.background = element_rect(color="black",fill = "white"),
      panel.grid.major = element_line(color="gray",linetype = 3)),
    ggspatial::annotation_scale(
        location="bl",
        height = unit(0.2,"cm")),
    ggspatial::annotation_north_arrow(
        location="tr",
        style = ggspatial::north_arrow_nautical,
        height = unit(1.5,"cm"),
        width = unit(1.5,"cm"))
    ) 
}