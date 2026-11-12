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
  galleryHeaderTop: string = ''
  galleryAccent: string = ''
  gallerySelection: string = ''
  galleryMuted: string = ''
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
  static readonly warning: string = '#FF9500'
  static readonly divider: string = '#E2E8F0'
  static readonly searchBackground: string = '#1E293B'

  private static readonly light: AppThemeColors = {
    glassSurface: '#D9FFFFFF',
    glassControl: '#B8F2F5FA',
    glassBorder: '#BFFFFFFF',
    glassTrack: '#CBD5E1',
    navigationMaterial: '#E6FFFFFF',
    menuBackground: '#FFFFFF',
    menuSelection: '#EFF6FF',
    imageErrorText: '#64748B',
    imagePlaceholder: '#F1F5F9',
    overlayBadge: '#F1F5F9',
    overlayBadgeText: '#1E293B',
    overlayTitle: '#0F172A',
    overlayText: '#1E293B',
    overlayMutedText: '#64748B',
    overlayAccentText: '#0A59F7',
    primaryButton: '#2563EB',
    secondaryButton: '#F1F5F9',
    secondaryButtonText: '#1E293B',
    overlaySurface: '#FFFFFF',
    background: '#EEF2F9',
    galleryTitle: '#0F172A',
    galleryHeaderTop: '#E2ECFF',
    galleryAccent: '#054ACB',
    gallerySelection: '#E2ECFF',
    galleryMuted: '#5C6C84',
    galleryControlText: '#1E293B',
    controlBackground: '#F1F5F9',
    textPrimary: '#0F172A',
    controlText: '#1E293B',
    textSecondary: '#475569',
    settingsPanel: '#FFFFFF',
    textMuted: '#94A3B8',
    cardSurface: '#FFFFFF',
    sourceButton: '#F1F5F9',
    sourceButtonText: '#0A59F7',
    switchSelected: '#0A59F7',
    tabSelected: '#0A59F7',
    tabUnselected: '#475569',
  }

  private static readonly dark: AppThemeColors = {
    glassSurface: '#E6151D2F',
    glassControl: '#B82A3445',
    glassBorder: '#40FFFFFF',
    glassTrack: '#334155',
    navigationMaterial: '#E60B0F19',
    menuBackground: '#131B2E',
    menuSelection: '#1E293B',
    imageErrorText: '#94A3B8',
    imagePlaceholder: '#151D2F',
    overlayBadge: '#1E293B',
    overlayBadgeText: '#F8FAFC',
    overlayTitle: '#FFFFFF',
    overlayText: '#F8FAFC',
    overlayMutedText: '#94A3B8',
    overlayAccentText: '#38BDF8',
    primaryButton: '#3B82F6',
    secondaryButton: '#1E293B',
    secondaryButtonText: '#F8FAFC',
    overlaySurface: '#131B2E',
    background: '#080C14',
    galleryTitle: '#F8FAFC',
    galleryHeaderTop: '#102039',
    galleryAccent: '#00D5FF',
    gallerySelection: '#12335A',
    galleryMuted: '#93A3BE',
    galleryControlText: '#F8FAFC',
    controlBackground: '#1E293B',
    textPrimary: '#F8FAFC',
    controlText: '#F8FAFC',
    textSecondary: '#CBD5E1',
    settingsPanel: '#131B2E',
    textMuted: '#94A3B8',
    cardSurface: '#131B2E',
    sourceButton: '#1E293B',
    sourceButtonText: '#60A5FA',
    switchSelected: '#3B82F6',
    tabSelected: '#60A5FA',
    tabUnselected: '#B6C4D8',
  }

  static color(isDark: boolean): AppThemeColors {
    return isDark ? AppTheme.dark : AppTheme.light
  }

  static cardShadow(isDark: boolean): string {
    return isDark ? '#40000000' : '#140F2E60'
  }
}
