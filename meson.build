project('com.github.aharotias2.genkoyoshi', 'vala', 'c', version: '0.0.1')

i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

add_project_arguments(
  [
    '--vapidir', meson.current_source_dir() / 'vapi',
    '--pkg', 'config'
  ],
  language: 'vala'
)

gnome = import('gnome')
resources = gnome.compile_resources(
  'genkoyoshi.resources',
  'data/gresources.xml',
  source_dir: 'data'
)

i18n.merge_file(
    input: join_paths('data', 'genkoyoshi.desktop.in'),
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

subdir('po')

config_h = configuration_data()
config_h.set_quoted('VERSION', '1.0.0')
config_h.set_quoted('APP_ID', meson.project_name())
config_h.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))

config_file = configure_file(
  output: 'config.h',
  configuration: config_h
)

project_config_dep = declare_dependency(
  sources: config_file,
  include_directories: include_directories('.')
)

executable(
  'com.github.aharotias2.genkoyoshi',
  [
    'src/main.vala',
    'src/app-window.vala',
    'src/genkoyoshi.vala',
    'src/text-model.vala',
    'src/text-element.vala',
    'src/cell-position.vala',
    'src/region.vala',
    'src/app-error.vala',
    'src/app-const.vala',
    'src/color-setting.vala',
    'src/font-setting.vala',
    'src/edit-mode.vala',
    'src/wrap-mode.vala',
    'src/availability.vala',
    'src/hurigana-helper.vala',
    'src/vertical-form-map.vala',
    'src/utf8-utils.vala',
    'src/conv-type.vala',
    'src/action-type.vala',
    'src/history-item.vala',
    'src/history.vala',
    'src/simple-list.vala',
    resources
  ],
  dependencies: [
    dependency('gtk+-3.0'),
    dependency('gee-0.8'),
    dependency('json-glib-1.0'),
    project_config_dep
  ],
  install: true,
  install_dir: get_option('prefix') / 'bin'
)


# テストの設定

## TextModelのテスト

text_model_tests = executable(
  'TextModelTests',
  [
    'test/text-model-tests.vala',
    'src/text-model.vala',
    'src/text-element.vala',
    'src/cell-position.vala',
    'src/region.vala',
    'src/app-error.vala',
    'src/edit-mode.vala',
    'src/wrap-mode.vala',
    'src/app-const.vala',
    'src/availability.vala',
    'src/hurigana-helper.vala',
    'src/vertical-form-map.vala',
    'src/utf8-utils.vala',
    'src/conv-type.vala',
    'src/action-type.vala',
    'src/history-item.vala',
    'src/history.vala',
    'src/simple-list.vala',
    resources
  ],
  dependencies: [
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8')
  ]
)

test('TextModelTests.construct_text_1', text_model_tests, args: ['construct_text_1'])
test('TextModelTests.construct_text_2', text_model_tests, args: ['construct_text_2'])
test('TextModelTests.construct_text_3', text_model_tests, args: ['construct_text_3'])
test('TextModelTests.construct_text_4', text_model_tests, args: ['construct_text_4'])
test('TextModelTests.get_contents_1', text_model_tests, args: ['get_contents_1'])
test('TextModelTests.get_contents_2', text_model_tests, args: ['get_contents_2'])
test('TextModelTests.count_lines_1', text_model_tests, args: ['count_lines_1'])
test('TextModelTests.count_lines_2', text_model_tests, args: ['count_lines_2'])
test('TextModelTests.count_visible_lines_1', text_model_tests, args: ['count_visible_lines_1'])
test('TextModelTests.count_visible_lines_2', text_model_tests, args: ['count_visible_lines_2'])
test('TextModelTests.insert_string_1', text_model_tests, args: ['insert_string_1'])
test('TextModelTests.insert_string_2', text_model_tests, args: ['insert_string_2'])
test('TextModelTests.insert_string_3', text_model_tests, args: ['insert_string_3'])
test('TextModelTests.insert_string_4', text_model_tests, args: ['insert_string_4'])
test('TextModelTests.insert_string_5', text_model_tests, args: ['insert_string_5'])
test('TextModelTests.insert_string_6', text_model_tests, args: ['insert_string_6'])
test('TextModelTests.insert_string_7', text_model_tests, args: ['insert_string_7'])
test('TextModelTests.insert_newline_1', text_model_tests, args: ['insert_newline_1'])
test('TextModelTests.delete_char_1', text_model_tests, args: ['delete_char_1'])
test('TextModelTests.delete_char_2', text_model_tests, args: ['delete_char_2'])
test('TextModelTests.delete_char_backward_1', text_model_tests, args: ['delete_char_backward_1'])
test('TextModelTests.delete_char_backward_2', text_model_tests, args: ['delete_char_backward_2'])
test('TextModelTests.delete_char_backward_3', text_model_tests, args: ['delete_char_backward_3'])
test('TextModelTests.delete_char_backward_4', text_model_tests, args: ['delete_char_backward_4'])
test('TextModelTests.delete_char_backward_5', text_model_tests, args: ['delete_char_backward_5'])
test('TextModelTests.delete_char_backward_6', text_model_tests, args: ['delete_char_backward_6'])
test('TextModelTests.preedit_changed_1', text_model_tests, args: ['preedit_changed_1'])
test('TextModelTests.preedit_changed_2', text_model_tests, args: ['preedit_changed_2'])
test('TextModelTests.preedit_changed_3', text_model_tests, args: ['preedit_changed_3'])
test('TextModelTests.preedit_changed_4', text_model_tests, args: ['preedit_changed_4'])
test('TextModelTests.preedit_changed_5', text_model_tests, args: ['preedit_changed_5'])
test('TextModelTests.preedit_changed_6', text_model_tests, args: ['preedit_changed_6'])
test('TextModelTests.delete_selection_1', text_model_tests, args: ['delete_selection_1'])
test('TextModelTests.delete_selection_2', text_model_tests, args: ['delete_selection_2'])
test('TextModelTests.delete_selection_3', text_model_tests, args: ['delete_selection_3'])
test('TextModelTests.delete_selection_4', text_model_tests, args: ['delete_selection_4'])
test('TextModelTests.delete_selection_5', text_model_tests, args: ['delete_selection_5'])

## CellPositionのテスト

cell_position_tests = executable(
  'CellPositionTests',
  [
    'test/cell-position-tests.vala',
    'src/cell-position.vala',
    'src/app-const.vala'
  ],
  dependencies: [
    dependency('gtk+-3.0')
  ]
)

foreach i : range(1, 41)
  test('CellPositionTests.@0@'.format(i), cell_position_tests, args: [i.to_string()])
endforeach

## HuriganaHelperのテスト

hurigana_helper_tests = executable(
  'HuriganaHelperTests',
  [
    'test/hurigana-helper-tests.vala',
    'src/hurigana-helper.vala'
  ],
  dependencies: [
    dependency('gtk+-3.0')
  ]
)

foreach i : range(1, 4)
  test('HuriganaHelperTest.@0@'.format(i), hurigana_helper_tests, args: [i.to_string()])
endforeach

## Utf8Utilsのテスト

utf8_utils_tests = executable(
  'Utf8UtilsTests',
  [
    'test/utf8-utils-tests.vala',
    'src/utf8-utils.vala'
  ],
  dependencies: [
    dependency('gtk+-3.0')
  ]
)

foreach i : range(1, 14)
  test('Utf8UtilsTest.@0@'.format(i), utf8_utils_tests, args: [i.to_string()])
endforeach

## SimpleListのテスト

simple_list_tests = executable(
  'SimpleListTests',
  [
    'test/simple-list-tests.vala',
    'src/simple-list.vala'
  ],
  dependencies: [
    dependency('glib-2.0'),
    dependency('gio-2.0')
  ]
)

foreach i : range(1, 48)
  test('SimpleListTest.@0@'.format(i), simple_list_tests, args: [i.to_string()])
endforeach
