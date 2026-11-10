/** Shared application colors. Keep light and dark palettes in sync by semantic role. */
class AppThemeColors {
  glassSurface: string = ''
  glassControl: string = ''
  glassBorder: string = ''
  glassTrack: string = ''
  navigationMaterial: string = ''
  menuBackground: string = ''
  menuSelection: string = ''
  imageErrorText: string = ''
  imagePlaceholder: string = ''
  overlayBadge: string = ''
  overlayBadgeText: string = ''
  overlayTitle: string = ''
  overlayText: string = ''
  overlayMutedText: string = ''
  overlayAccentText: string = ''
  primaryButton: string = ''
  secondaryButton: string = ''
  secondaryButtonText: string = ''
  overlaySurface: string = ''
  background: string = ''
  galleryTitle: string = ''
  galleryControlText: string = ''
  controlBackground: string = ''
  textPrimary: string = ''
  controlText: string = ''
  textSecondary: string = ''
  settingsPanel: string = ''
  textMuted: string = ''
  cardSurface: string = ''
  sourceButton: string = ''
  sourceButtonText: string = ''
  switchSelected: string = ''
  tabSelected: string = ''
  tabUnselected: string = ''
}

export class AppTheme {
  static readonly onPrimary: string = '#FFFFFF'
  static readonly danger: string = '#FF3B30'
  static readonly info: string = '#3F82FF'
  static readonly success: string = '#00C997'
  static readonly divider: string = '#EEEEEE'
  static readonly searchBackground: string = '#222'

  private static readonly light: AppThemeColors = {
    glassSurface: '#E8FFFFFF',
    glassControl: '#E6F0F4FC',
    glassBorder: '#DFFFFFFF',
    glassTrack: '#B8C8C8BE',
    navigationMaterial: '#E8F7F4ED',
    menuBackground: '#FFFDF8',
    menuSelection: '#E3E9DE',
    imageErrorText: '#7A796E',
    imagePlaceholder: '#E9E5DB',
    overlayBadge: '#E6E9E3D7',
    overlayBadgeText: '#443A30',
    overlayTitle: '#30251F',
    overlayText: '#382820',
    overlayMutedText: '#81766A',
    overlayAccentText: '#286FF2',
    primaryButton: '#286FF2',
    secondaryButton: '#E1DDCF',
    secondaryButtonText: '#483F34',
    overlaySurface: '#E6F7F2E9',
    background: '#F2F5FA',
    galleryTitle: '#382820',
    galleryControlText: '#4B4435',
    controlBackground: '#E7E2D3',
    textPrimary: '#382820',
    controlText: '#493F34',
    textSecondary: '#53483B',
    settingsPanel: '#EEE9DD',
    textMuted: '#81766A',
    cardSurface: '#FFFDF8',
    sourceButton: '#E6E1D5',
    sourceButtonText: '#617A62',
    switchSelected: '#286FF2',
    tabSelected: '#286FF2',
    tabUnselected: '#81766A',
  }

  private static readonly dark: AppThemeColors = {
    glassSurface: '#E61D222D',
    glassControl: '#E62C3444',
    glassBorder: '#40FFFFFF',
    glassTrack: '#FF30394A',
    navigationMaterial: '#D91B2230',
    menuBackground: '#1B202A',
    menuSelection: '#465D68',
    imageErrorText: '#B9C8D3',
    imagePlaceholder: '#252C32',
    overlayBadge: '#CC303D47',
    overlayBadgeText: '#F2F6F8',
    overlayTitle: '#FFFFFF',
    overlayText: '#F0F3F5',
    overlayMutedText: '#B8C5CE',
    overlayAccentText: '#6FA3FF',
    primaryButton: '#547A8C',
    secondaryButton: '#2C3444',
    secondaryButtonText: '#E3EFF3',
    overlaySurface: '#E6222930',
    background: '#0E1015',
    galleryTitle: '#F3F5F5',
    galleryControlText: '#26333B',
    controlBackground: '#D7E3E8',
    textPrimary: '#F1F5F5',
    controlText: '#26333B',
    textSecondary: '#DCE7EC',
    settingsPanel: '#1B202A',
    textMuted: '#B5C2CB',
    cardSurface: '#1B202A',
    sourceButton: '#2C3444',
    sourceButtonText: '#BCDCE9',
    switchSelected: '#347BFF',
    tabSelected: '#6FA3FF',
    tabUnselected: '#A8B5BC',
  }

  static color(isDark: boolean): AppThemeColors {
    return isDark ? AppTheme.dark : AppTheme.light
  }
}
