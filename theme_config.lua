local Theme = {}

local fontsCache = {}

Theme.fonts = {
  header = function()
    if not fontsCache.header then
      fontsCache.header = ui.DWriteFont('Inter:/assets/fonts/Roboto-Medium.ttf;Weight=SemiBold')
    end
    return fontsCache.header
  end,
  body = function()
    if not fontsCache.body then
      fontsCache.body = ui.DWriteFont('Inter:/assets/fonts/Roboto-Medium.ttf;Weight=Regular')
    end
    return fontsCache.body
  end,
  mono = function()
    if not fontsCache.mono then
      fontsCache.mono = ui.DWriteFont('InterMono:/assets/fonts/Roboto-Medium.ttf;Weight=SemiBold')
    end
    return fontsCache.mono
  end
}

Theme.themes = {
  dark = {
    name = 'Dark',
    colors = {
      background = rgbm(0.06, 0.06, 0.07, 0.92),
      card = rgbm(0.12, 0.12, 0.14, 0.95),
      border = rgbm(1, 1, 1, 0.06),
      text = rgbm(0.94, 0.96, 1, 1),
      textDim = rgbm(0.72, 0.76, 0.82, 1),
      accent = rgbm(0.2, 0.58, 1, 1),
      green = rgbm(0.3, 0.9, 0.55, 1),
      red = rgbm(0.98, 0.28, 0.3, 1),
      orange = rgbm(0.99, 0.63, 0.25, 1),
      purple = rgbm(0.75, 0.5, 1, 1),
      cyan = rgbm(0.35, 0.9, 0.95, 1),
      muted = rgbm(0.35, 0.4, 0.45, 1),
      warning = rgbm(1, 0.85, 0.3, 1)
    },
    sizing = {
      padding = 12,
      radius = 8,
      gap = 8,
      line = 1,
      microHeight = 10
    }
  },
  amoled = {
    name = 'AMOLED',
    colors = {
      background = rgbm(0, 0, 0, 0.92),
      card = rgbm(0.05, 0.05, 0.06, 0.96),
      border = rgbm(1, 1, 1, 0.08),
      text = rgbm(0.95, 0.97, 1, 1),
      textDim = rgbm(0.66, 0.72, 0.78, 1),
      accent = rgbm(0.4, 0.85, 1, 1),
      green = rgbm(0.18, 0.82, 0.42, 1),
      red = rgbm(1, 0.32, 0.36, 1),
      orange = rgbm(1, 0.64, 0.35, 1),
      purple = rgbm(0.85, 0.5, 1, 1),
      cyan = rgbm(0.42, 0.98, 1, 1),
      muted = rgbm(0.32, 0.36, 0.42, 1),
      warning = rgbm(1, 0.86, 0.4, 1)
    },
    sizing = {
      padding = 12,
      radius = 10,
      gap = 8,
      line = 1,
      microHeight = 10
    }
  }
}

function Theme.get(settings)
  local choice = settings and settings.theme or 'dark'
  local theme = Theme.themes[choice] or Theme.themes.dark
  return {
    name = theme.name,
    colors = theme.colors,
    sizing = theme.sizing,
    fonts = {
      header = Theme.fonts.header(),
      body = Theme.fonts.body(),
      mono = Theme.fonts.mono()
    }
  }
end

function Theme.applyWindow(windowName, theme)
  if not theme then return end
  ac.setWindowBackground(windowName, theme.colors.background)
end

return Theme
