#Début de la procédure d'affichage de la carte
# open the file
png(filename = "mapcmr.png", w = 7, h = 7, units = "in", res = 150)
# make the map palette = "RdYlGn"
tm_shape(cmr_datasf) +
  tm_style("natural", bg.color = "grey90") +
  tm_fill("FRRS4", title = "Niveau d'étude", palette = "RdYlGn", 
          breaks = seq(0, 18, by=1)) +
  tm_scale_bar(width = 0.22, position = c("center", 0.01)) +
  tm_compass(position = c("center", 0.05)) +
  tm_layout(inner.margins=c(0.1,0.02,0.02,0.02), legend.title.size = 1.5, legend.text.size = 0.7) +
  tm_graticules(lines = FALSE) +
tm_shape(regions) +
  tm_borders(lwd = 1) +
  tm_text("ADM1_FR", size = 1, fontface = "bold") 
# close the png file
dev.off()