/** Shared application colors. Keep light and dark palettes in sync by semantic role. */
class AppThemeColors {
  glassSurface: string = ''
  glassControl: string = ''
  glassBorder: string = ''
  glassTrack: string = ''
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
  static readonly info: string = '#007DFF'
  static readonly success: string = '#34C759'
  static readonly divider: string = '#EEEEEE'
  static readonly searchBackground: string = '#222'

  private static readonly light: AppThemeColors = {
    glassSurface: '#BFFFFFFF',
    glassControl: '#B8FFFFFF',
    glassBorder: '#DFFFFFFF',
    glassTrack: '#B8C8C8BE',
    imageErrorText: '#7A796E',
    imagePlaceholder: '#E9E5DB',
    overlayBadge: '#E6E9E3D7',
    overlayBadgeText: '#443A30',
    overlayTitle: '#30251F',
    overlayText: '#382820',
    overlayMutedText: '#81766A',
    overlayAccentText: '#738A72',
    primaryButton: '#738A72',
    secondaryButton: '#E1DDCF',
    secondaryButtonText: '#483F34',
    overlaySurface: '#E6F7F2E9',
    background: '#F7F2E9',
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
    switchSelected: '#738A72',
    tabSelected: '#526D50',
    tabUnselected: '#81766A',
  }

  private static readonly dark: AppThemeColors = {
    glassSurface: '#B83B4851',
    glassControl: '#B85D707B',
    glassBorder: '#667E929C',
    glassTrack: '#B85A6971',
    imageErrorText: '#B9C8D3',
    imagePlaceholder: '#252C32',
    overlayBadge: '#CC303D47',
    overlayBadgeText: '#F2F6F8',
    overlayTitle: '#FFFFFF',
    overlayText: '#F0F3F5',
    overlayMutedText: '#B8C5CE',
    overlayAccentText: '#A8D7EA',
    primaryButton: '#547A8C',
    secondaryButton: '#354650',
    secondaryButtonText: '#E3EFF3',
    overlaySurface: '#E6222930',
    background: '#171A20',
    galleryTitle: '#F3F5F5',
    galleryControlText: '#26333B',
    controlBackground: '#D7E3E8',
    textPrimary: '#F1F5F5',
    controlText: '#26333B',
    textSecondary: '#DCE7EC',
    settingsPanel: '#252E35',
    textMuted: '#B5C2CB',
    cardSurface: '#252E35',
    sourceButton: '#354650',
    sourceButtonText: '#BCDCE9',
    switchSelected: '#83BDD2',
    tabSelected: '#365C6E',
    tabUnselected: '#59666B',
  }

  static color(isDark: boolean): AppThemeColors {
    return isDark ? AppTheme.dark : AppTheme.light
  }
}
