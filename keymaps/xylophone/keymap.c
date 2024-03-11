/* Copyright 2023 Gerry Hernandez (@gplusplus314)
 * Copyright 2023 Cyboard LLC (@Cyboard-DigitalTailor)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include QMK_KEYBOARD_H

enum G_LAYERS {
  GL_BASE = 0,
  GL_ASALPHA,
  GL_GAME,
  GL_NAVSYM,
  GL_WM,
  GL_FN,
  GL_STNGS,
  GL_TRANS
};

bool is_in_gaming_context(keyrecord_t *record) {
  return IS_LAYER_ON(GL_GAME) && record->event.key.col < 7;
}

// High Level Key Definitions {{{
enum G_KEYCODES {
  GK_LPRN = SAFE_RANGE,
  GK_RPRN,
  GK_UNDER,
  GK_SETTINGS,
  GK_S_AS // Setting: Alpha Auto Shift
};

// Left Thumbs Mod-Taps:
#define G_SPC    LCTL_T(KC_SPC)
#define G_ESC    LALT_T(KC_ESC)
// Right Thumbs Layer-Taps:
#define G_ENT    LT(GL_WM, KC_ENT)
#define G_BSPC   LT(GL_NAVSYM, KC_BSPC)
// Pinkies Mod-Taps:
#define G_A      LSFT_T(KC_A)
#define G_O      RSFT_T(KC_O)
// Pinkies Combo:
#define G_CAPZ   QK_CAPS_WORD_TOGGLE
// Left Finger Combos:
#define G_TAB    KC_TAB
#define G_LPRN   GK_LPRN
#define G_LBRC   KC_LBRC
#define G_MINS   KC_MINS
#define G_WMPREV G(KC_UP)
#define G_LEFT   KC_LEFT
// Right Finger Combos:
#define G_QUOT   KC_QUOT
#define G_RPRN   GK_RPRN
#define G_RBRC   KC_RBRC
#define G_EQL    KC_EQL
#define G_WMNEXT G(KC_DOWN)
#define G_RGHT   KC_RGHT
#define G_DEL    KC_DEL
// Left Thumb Combos:
#define G_LGUI   KC_LGUI
// Right Thumb Combos:
#define G_FN     MO(GL_FN)
// Left Thumb WM Layer:
#define G_CTLSPC LCTL_T(C(KC_SPC))
#define G_ALTESC LALT_T(A(KC_ESC))
// Left Thumb Combo in Navsym Layer:
#define G_GUISPC LGUI_T(G(KC_SPC))
// High Level Key Definitions }}}

// Combo Definitions {{{
#include "g/keymap_combo.h" // combos defined in combos.def

bool combo_should_trigger(uint16_t combo_index, combo_t *combo, uint16_t keycode, keyrecord_t *record) {
  if(is_in_gaming_context(record)) {
    return false;
  }

  if(combo_index == GC_LGUI) {
    return layer_state >> GL_GAME == 0 || IS_LAYER_ON(GL_NAVSYM);
  }

  return layer_state >> GL_GAME == 0;
}
// Combo Definitions }}}

// Timing settings {{{
uint16_t get_combo_term(uint16_t index, combo_t *combo) {
  // or with combo index, i.e. its name from enum.
  switch (index) {
    case GC_TAB:
    case GC_QUOT:
    case GC_MINS:
    case GC_EQL:
      return 25;
      
    default:
      return 35;
  }
}

uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    default:
      return 175;
  }
}
// Timing settings }}}

// Behavior {{{
// https://docs.qmk.fm/#/feature_auto_shift?id=custom-shifted-values
void autoshift_press_user(uint16_t keycode, bool shifted, keyrecord_t *record) {
    switch(keycode) {
        case GK_LPRN:
            tap_code16((!shifted) ? S(KC_9) : S(KC_COMMA));
            break;
        case GK_RPRN:
            tap_code16((!shifted) ? S(KC_0) : S(KC_DOT));
            break;
        default:
            if (shifted) {
                add_weak_mods(MOD_BIT(KC_LSFT));
            }
            // & 0xFF gets the Tap key for Tap Holds, required when using Retro Shift
            register_code16((IS_RETRO(keycode)) ? keycode & 0xFF : keycode);
    }
}


void autoshift_release_user(uint16_t keycode, bool shifted, keyrecord_t *record) {
    switch(keycode) {
        default:
            // & 0xFF gets the Tap key for Tap Holds, required when using Retro Shift
            // The IS_RETRO check isn't really necessary here, always using
            // keycode & 0xFF would be fine.
            unregister_code16((IS_RETRO(keycode)) ? keycode & 0xFF : keycode);
    }
}

bool get_auto_shifted_key(uint16_t keycode, keyrecord_t *record) {
  if(is_in_gaming_context(record)) {
    return false;
  }

  switch (keycode) {
    case KC_A ... KC_Z:
      return IS_LAYER_ON(GL_ASALPHA);

    case KC_1 ... KC_0:
    case KC_TAB:
    case KC_MINUS ... KC_SLASH:
    case KC_NONUS_BACKSLASH:
    case GK_LPRN:
    case GK_RPRN:
      return true;
  }
  return false;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    // Example of complex multifunction key:
    //case G_UNDER:
    //  if(record->tap.count && record->event.pressed) {
    //    if(IS_LAYER_ON(GL_NAVSYM)) {
    //      unregister_mods(MOD_BIT(KC_LGUI));
    //      tap_code16(G(KC_SPC));
    //    } else {
    //      unregister_mods(MOD_BIT(KC_LGUI));
    //      tap_code16(S(KC_MINS));
    //    }
    //  } else {
    //    if(record->event.pressed) {
    //      register_mods(MOD_BIT(KC_LGUI));
    //    } else {
    //      unregister_mods(MOD_BIT(KC_LGUI));
    //    }
    //  }
    //  return false;

    case GK_SETTINGS:
      if (record->event.pressed) {
        layer_on(GL_STNGS);
      } else {
        // Do something else when release
      }
      return false; // Skip all further processing of this key

    case GK_S_AS:
      layer_invert(GL_ASALPHA);
      layer_off(GL_STNGS);
      return false;

    default:
      return true; // Process all other keycodes normally
  }
}

bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    //case LT(1, KC_BSPC):
    //  // Do not select the hold action when another key is tapped.
    //  return false;
    default:
      // Immediately select the hold action when another key is tapped.
      return true;
  }
}

bool get_hold_on_other_key_press(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    //case SFT_T(KC_SPC):
    //  // Force the dual-role key press to be handled as a modifier if any
    //  // other key was pressed while the mod-tap key is held down.
    //  return true;
    default:
      // Do not force the mod-tap key press to be handled as a modifier
      // if any other key was pressed while the mod-tap key is held down.
      return false;
  }
}
// Behavior }}}

// Layers {{{
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

    [GL_BASE] = LAYOUT_singlearc_number_row(
        _______, _______, _______, _______, _______,     _______,                       _______, _______, _______, _______, _______, _______,
        _______, KC_Q,    KC_W,    KC_F,    KC_P,        KC_B,                          KC_J,    KC_L,    KC_U,    KC_Y,    KC_SCLN, _______, 
        _______, G_A,     KC_R,    KC_S,    KC_T,        KC_G,                          KC_M,    KC_N,    KC_E,    KC_I,    G_O,     _______, 
        _______, KC_Z,    KC_X,    KC_C,    KC_D,        KC_V,                          KC_K,    KC_H,    KC_COMM, KC_DOT,  KC_SLSH, _______, 
        _______, _______, _______, _______, TT(GL_GAME), G_SPC,   G_ESC,       G_ENT,   G_BSPC,  _______, _______, _______, _______, _______
    ),

    [GL_ASALPHA] = LAYOUT_singlearc_number_row(
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, KC_A,    _______, _______, _______, _______,                           _______, _______, _______, _______, KC_O,    _______,
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______, _______,         _______, _______, _______, _______, _______, _______, _______
    ),

    [GL_GAME] = LAYOUT_singlearc_number_row(
        KC_RBRC, KC_1,    KC_2,    KC_3,    KC_4,    KC_5,                              KC_6,    KC_7,        KC_8,    KC_9,    KC_0,    KC_ESC,
        KC_TAB,  _______, _______, _______, _______, _______,                           _______, _______,     _______, _______, _______, KC_GRV,
        KC_LSFT, KC_A,    _______, _______, _______, _______,                           _______, _______,     _______, _______, _______, KC_BSLS,
        KC_LBRC, _______, _______, _______, _______, _______,                           _______, _______,     _______, _______, _______, KC_EQL,
        KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_LALT, KC_SPC, KC_LCTL,          _______, _______, TT(GL_GAME), KC_HOME, KC_PGDN, KC_PGUP, KC_END
    ),

    [GL_NAVSYM] = LAYOUT_singlearc_number_row(
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, KC_HOME, KC_UP,   KC_END,  KC_PGUP,                           KC_LBRC, KC_4,    KC_5,    KC_6,    KC_DOT,  _______,
        _______, _______, KC_LEFT, KC_DOWN, KC_RGHT, KC_PGDN,                           KC_GRV,  KC_1,    KC_2,    KC_3,    KC_0,    _______,
        _______, _______, KC_LBRC, G_LPRN,  G_RPRN,  KC_RBRC,                           KC_RBRC, KC_7,    KC_8,    KC_9,    KC_BSLS, _______,
        _______, _______, _______, _______, _______, _______, _______,         _______, _______, _______, _______, _______, _______, _______
    ),

    [GL_WM] = LAYOUT_singlearc_number_row(
        _______, _______, _______, _______, _______, _______,                           _______,    _______, _______, _______, _______,    _______,
        _______, _______, _______, KC_BRID, KC_BRIU, _______,                           G(KC_LBRC), G(KC_4), G(KC_5), G(KC_6), G(KC_RGHT), _______,
        _______, _______, _______, KC_VOLD, KC_VOLU, KC_MUTE,                           G(KC_GRV),  G(KC_1), G(KC_2), G(KC_3), G(KC_0),    _______,
        _______, _______, _______, KC_MPRV, KC_MNXT, KC_MPLY,                           G(KC_RBRC), G(KC_7), G(KC_8), G(KC_9), G(KC_LEFT), _______,
        _______, _______, _______, _______, _______, G_CTLSPC, G_ALTESC,       _______, _______,    _______, _______, _______, _______,    _______
    ),

    [GL_FN] = LAYOUT_singlearc_number_row(
        _______, _______, _______, _______, _______, _______,                           _______, _______,       _______,       _______,       _______,        _______,
        _______, _______, _______, _______, _______, _______,                           KC_F14,  KC_F4,         KC_F5,         KC_F6,         KC_F11,         _______,
        _______, KC_LSFT, KC_LGUI, KC_LALT, KC_LCTL, _______,                           KC_F13,  RCTL_T(KC_F1), RALT_T(KC_F2), RGUI_T(KC_F3), RSFT_T(KC_F10), _______,
        _______, _______, _______, _______, _______, _______,                           KC_F15,  KC_F7,         KC_F8,         KC_F9,         KC_F12,         _______,
        _______, _______, _______, _______, _______, _______, _______,         _______, _______, _______,       _______,       _______,       _______,        _______
    ),

    [GL_STNGS] = LAYOUT_singlearc_number_row(
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______,                           _______, GK_S_AS, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______, _______,         _______, _______, _______, _______, _______, _______, _______
    ),

    [GL_TRANS] = LAYOUT_singlearc_number_row(
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______,                           _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______, _______,         _______, _______, _______, _______, _______, _______, _______
    )
};
// Layers }}}
