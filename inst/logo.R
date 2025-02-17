library(ggplot2)
library(scales)
library(hexSticker)
install.packages('rsvg')
remotes::install_github('coolbutuseless/ggsvg')
library(ggsvg)

svg_txt <- readLines("inst/dice.svg")
ap <- ggplot() +
  geom_point_svg(data = data.frame(x = 1, y = 1),
                 aes(x, y), svg = svg_txt, size = 25) +
  theme_void() + theme_transparent()
ap
s <- sticker(ap, package="",
             s_x=1, s_y=1, s_width=2, s_height=2,
             filename="man/figures/logo.png",
             h_fill = colorRampPalette(c("white", CTUtemplate::unibeRed()))(6)[3],
             h_color = CTUtemplate::unibeRed(),
             h_size = 2,
             url = "randolist",
             u_size = 12,
             u_x = 1,
             u_y = 0.15
)
s

pkgdown::build_favicons(overwrite = TRUE)
