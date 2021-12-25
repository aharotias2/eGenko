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
    'src/appwindow.vala',
    'src/genkoyoshi.vala',
    'src/textmodel.vala',
    'src/textelement.vala',
    'src/cellposition.vala',
    'src/apperror.vala',
    'src/appconst.vala',
    'src/colorsetting.vala',
    'src/fontsettings.vala',
    'src/editmode.vala',
    'src/wrapmode.vala',
    'src/availability.vala',
    'src/huriganahelper.vala',
    'src/verticalformmap.vala',
    'src/utf8utils.vala',
    'src/convtype.vala',
    'src/actiontype.vala',
    'src/historyitem.vala',
    'src/simplelist.vala',
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

textmodeltests = executable(
  'TextModelTests',
  [
    'test/textmodeltests.vala',
    'src/textmodel.vala',
    'src/textelement.vala',
    'src/cellposition.vala',
    'src/apperror.vala',
    'src/editmode.vala',
    'src/wrapmode.vala',
    'src/appconst.vala',
    'src/availability.vala',
    'src/huriganahelper.vala',
    'src/verticalformmap.vala',
    'src/utf8utils.vala',
    'src/convtype.vala',
    'src/actiontype.vala',
    'src/historyitem.vala',
    'src/simplelist.vala',
    resources
  ],
  dependencies: [
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8')
  ]
)

test('TextModelTests.get_contents_1', textmodeltests, args: ['get_contents_1'])
test('TextModelTests.get_contents_2', textmodeltests, args: ['get_contents_2'])
test('TextModelTests.count_lines_1', textmodeltests, args: ['count_lines_1'])
test('TextModelTests.count_lines_2', textmodeltests, args: ['count_lines_2'])
test('TextModelTests.count_visible_lines_1', textmodeltests, args: ['count_visible_lines_1'])
test('TextModelTests.count_visible_lines_2', textmodeltests, args: ['count_visible_lines_2'])
test('TextModelTests.insert_string_1', textmodeltests, args: ['insert_string_1'])
test('TextModelTests.insert_string_2', textmodeltests, args: ['insert_string_2'])
test('TextModelTests.insert_string_3', textmodeltests, args: ['insert_string_3'])
test('TextModelTests.insert_string_4', textmodeltests, args: ['insert_string_4'])
test('TextModelTests.insert_string_5', textmodeltests, args: ['insert_string_5'])
test('TextModelTests.insert_string_6', textmodeltests, args: ['insert_string_6'])
test('TextModelTests.insert_string_7', textmodeltests, args: ['insert_string_7'])
test('TextModelTests.insert_newline_1', textmodeltests, args: ['insert_newline_1'])
test('TextModelTests.delete_char_1', textmodeltests, args: ['delete_char_1'])
test('TextModelTests.delete_char_2', textmodeltests, args: ['delete_char_2'])
test('TextModelTests.delete_char_backward_1', textmodeltests, args: ['delete_char_backward_1'])
test('TextModelTests.delete_char_backward_2', textmodeltests, args: ['delete_char_backward_2'])
test('TextModelTests.delete_char_backward_3', textmodeltests, args: ['delete_char_backward_3'])
test('TextModelTests.delete_char_backward_4', textmodeltests, args: ['delete_char_backward_4'])
test('TextModelTests.delete_char_backward_5', textmodeltests, args: ['delete_char_backward_5'])
test('TextModelTests.delete_char_backward_6', textmodeltests, args: ['delete_char_backward_6'])
test('TextModelTests.preedit_changed_1', textmodeltests, args: ['preedit_changed_1'])
test('TextModelTests.preedit_changed_2', textmodeltests, args: ['preedit_changed_2'])
test('TextModelTests.preedit_changed_3', textmodeltests, args: ['preedit_changed_3'])
test('TextModelTests.preedit_changed_4', textmodeltests, args: ['preedit_changed_4'])
test('TextModelTests.preedit_changed_5', textmodeltests, args: ['preedit_changed_5'])
test('TextModelTests.preedit_changed_6', textmodeltests, args: ['preedit_changed_6'])
test('TextModelTests.delete_selection_1', textmodeltests, args: ['delete_selection_1'])
test('TextModelTests.delete_selection_2', textmodeltests, args: ['delete_selection_2'])
test('TextModelTests.delete_selection_3', textmodeltests, args: ['delete_selection_3'])
test('TextModelTests.delete_selection_4', textmodeltests, args: ['delete_selection_4'])
test('TextModelTests.delete_selection_5', textmodeltests, args: ['delete_selection_5'])

## CellPositionのテスト

cellpositiontests = executable(
  'CellPositionTests',
  [
    'test/cellpositiontest.vala',
    'src/cellposition.vala',
    'src/appconst.vala'
  ],
  dependencies: [
    dependency('gtk+-3.0')
  ]
)

foreach i : range(1, 41)
  test('CellPositionTests.@0@'.format(i), cellpositiontests, args: [i.to_string()])
endforeach

## HuriganaHelperのテスト

huriganahelpertests = executable(
  'HuriganaHelperTests',
  [
    'test/huriganahelpertest.vala',
    'src/huriganahelper.vala'
  ],
  dependencies: [
    dependency('gtk+-3.0')
  ]
)

foreach i : range(1, 4)
  test('HuriganaHelperTest.@0@'.format(i), huriganahelpertests, args: [i.to_string()])
endforeach

## Utf8Utilsのテスト

utf8utilstests = executable(
  'Utf8UtilsTests',
  [
    'test/utf8utilstest.vala',
    'src/utf8utils.vala'
  ],
  dependencies: [
    dependency('gtk+-3.0')
  ]
)

foreach i : range(1, 14)
  test('Utf8UtilsTest.@0@'.format(i), utf8utilstests, args: [i.to_string()])
endforeach

## SimpleListのテスト

simplelisttests = executable(
  'SimpleListTests',
  [
    'test/simplelisttest.vala',
    'src/simplelist.vala'
  ],
  dependencies: [
    dependency('glib-2.0'),
    dependency('gio-2.0')
  ]
)

foreach i : range(1, 27)
  test('SimpleListTest.@0@'.format(i), simplelisttests, args: [i.to_string()])
endforeach
