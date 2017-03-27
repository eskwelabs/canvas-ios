/**
 * @flow
 */

import 'react-native'
import { branding, setupBrandingFromNativeBrandingInfo } from '../branding'

describe('setupBrandingFromNativeBrandingInfo', () => {
  it('uses defaults', () => {
    const expected = { ...branding }
    setupBrandingFromNativeBrandingInfo({})
    expect(branding).toEqual(expected)
  })

  it('parses native branding info', () => {
    let expected = {
      navBgColor: 'navBgColor',
      primaryButtonTextColor: 'primaryButtonTextColor',
      primaryButtonColor: 'primaryButtonColor',
      fontColorDark: 'fontColorDark',
      headerImage: './src/images/canvas-logo.png',
      navButtonColor: 'navButtonColor',
      primaryBrandColor: '#374A59',
    }

    let input = {
      'ic-brand-global-nav-bgd': 'navBgColor',
      'ic-brand-button--primary-text': 'primaryButtonTextColor',
      'ic-brand-button--primary-bgd': 'primaryButtonColor',
      'ic-brand-font-color-dark': 'fontColorDark',
      'ic-brand-header-image': 'headerImage',
      'ic-brand-global-nav-ic-icon-svg-fill': 'navButtonColor',
    }
    setupBrandingFromNativeBrandingInfo(input)

    expect(branding).toEqual(expected)
  })
})
