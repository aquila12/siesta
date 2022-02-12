NOKIA_LCD_LIGHT := "\#c7f0d8"
NOKIA_LCD_DARK  := "\#43523d"

all: leveltiles.png leveltiles-inverse.png skytiles.png skyobjects.png logo-4x.png

%-inverse.png: src/%.png
	convert $< +level-colors $(NOKIA_LCD_LIGHT),$(NOKIA_LCD_DARK) $@

%.png : src/%.png
	convert $< +level-colors $(NOKIA_LCD_DARK),$(NOKIA_LCD_LIGHT) $@

%-4x.png: %.png
	convert $< -scale 400% $@
