<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

return PhpCsFixer\Config::create()
    ->setRiskyAllowed(true)
    ->setRules(array(
        '@PSR2' => true,

        /**
         * Each line of a multi-line PHPDoc comment must have an
         * asterisk and must be aligned with the first one.
         *
         * comment_type:
         *  phpdocs_only:   fix PHPDoc comments only
         *  phpdocs_like:   any multi-line comment whose lines all start with an asterisk
         *  all_multiline:  any multi-line comment
         *
         * default: phpdocs_only
         */
        'align_multiline_comment' => array('comment_type' => 'phpdocs_like'),

        /**
         * PHP arrays should be declared using the configured syntax.
         *
         * syntax:
         *  short:  does not append `array` to initialized arrays:
         *          $a = ["stuff" => "junk" ];
         *  long:   appends `array` to initialized arrays:
         *          $a = array("stuff" => "junk");
         *
         * default: long
         */
        'array_syntax' => array('syntax' => 'long'),

        /**
         * Converts backtick operators to shell_exec calls.
         *
         * (true, false)
         */
        'backtick_to_shell_exec' => false,

        /**
         * Binary operators should be surrounded by space as configured.
         *
         * Applies to @Symfony rules only
         *
         * align_double_arrow (false, null, true): (deprecated) Whether to apply, remove, or ignore double arrows alignment (default: true)
         * align_equals (false, null, true): (deprecated) Whether to apply, remove, or ignore equals alignment (default: false)
         * default (align, align_single_space, align_single_space_miminal, single_space, null)
         *  Default fix strategy (default: single_space)
         * operators (array):
         *  Dictionary of 'binary operator' => 'fix strategy' values that differ from the default strategy (default: [])
         */
        'binary_operator_spaces' => array(
            'align_double_arrow' => false,
            'align_equals' => false,
        ),

        /**
         * There MUST be one blank line after the namespace declaration.
         *
         * (true,false)
         */
        'blank_line_after_namespace' => true,

        /**
         * Ensure there is no code on the same line as the PHP open tag
         * and it is followed by a blank line.
         *
         * (true,false)
         */
        'blank_line_after_opening_tag' => true,

        /**
         * An empty line must precede any configured statement.
         *
         * statements (array): list of statements which must be preceded by an empty line
         */
        'blank_line_before_statement' => array('statements' => array('break', 'return', 'throw', 'try')),

        /**
         * The body of each structure MUST be enclosed by braces. Braces should be properly placed. Body
         * of braces shold be properly indented.
         *
         * allow_single_line_closure (bool):
         *  Whether single line lambda notation should be allows (default: false)
         * position_after_anonymous_constructs ('next', 'same'):
         *  Whether the opening brace should be placed on "next" or "same" line after anonymous
         *  constructs (anon classes and lambdas) (default: 'same')
         * position_after_control_structures ('next', 'same'):
         *  Whether the opening brace should be placed on "next" or "same" line after control
         *  structures (default: 'same')
         * position_after_functions_and_oop_constructs ('next', 'same'):
         *  Whether the opening brace should be placed on "next" or "same" line after classy
         *  constructs (non-anon classes, interfaces, traits, methods, and non-lambda functions) (default: 'next')
         */
        'braces' => array(
            'allow_single_line_closure' => false,
            'position_after_anonymous_constructs' => 'same',
            'position_after_control_structures' => 'next',
            'position_after_functions_and_oop_constructs' => 'next',
        ),

        /**
         * A single space or none should be between cast and variable.
         *
         * space ('none', 'single'): spacing to apply between cast and variable (default: 'single')
         */
        'cast_spaces' => array('space' => 'none'),

        /**
         * Class, trait, and interface elements must be separated with one blank line.
         *
         * elements (array): list of classy elements
         */
        'class_attributes_separation' => array('elements' => array('const', 'method', 'property')),

        /**
         * Whitespace around the keywords of a class, trait, or interfaces definition should be one space.
         *
         * multiLineExtendsEachSingleLine (bool): Whether definitions should be multiline (default: false)
         * singleItemSingleLine (bool): Whether definitions should be single line when including a single item (default: false)
         * singleLine (bool): Whether definitions should be single line (default: false)
         */
        // 'class_definition' => array('singleLine' => true),

        /**
         * Converts ::class keywords to FQCN strings.
         *
         * (true/false)
         */
        'class_keyword_remove' => false,

        /**
         * Using `isset($var) &&` multiple times should be done in one call.
         *
         * (true/false)
         */
        'combine_consecutive_issets' => false,

        /**
         * Calling unset on multiple items should be done in one call.
         *
         * (true/false)
         */
        'combine_consecutive_unsets' => true,

        /**
         * Remove extra spaces in a nullable typehint.
         *
         * (true/false)
         */
        'compact_nullable_typehint' => true,

        /**
         * Concatenation should be spaced according to configuration.
         *
         * spacing ('none', 'one'): spacing to apply around concatenation operator
         */
        'concat_space' => array('spacing' => 'one'),

        /**
         * Equal sign in declare statement should be surrounded by spaces or not.
         *
         * space ('none', 'single'): spacing to apply around the equal sign
         */
        'declare_equal_normalize' => array('space' => 'single'),

        /**
         * Force strict types declaration in all files. Requires PHP>=7.0.
         * Risky rule: forcing strict types will stop non strict code from working.
         */
        'declare_strict_types' => false,

        /**
         * Replaces `dirname(__FILE___) expression with equivalent `__DIR__` constant.
         * Risky rule: risky when the function `dirname` is overridden.
         */
        'dir_constant' => false,

        /**
         * The keyword `elseif` should be used instead of `else if` so all control keywords
         * look like single words.
         *
         * (true/false)
         */
        'elseif' => false,

        /**
         * PHP code MUST use only UTF-8 without BOM (remove BOM).
         *
         * https://www.w3.org/International/questions/qa-byte-order-mark
         *
         * (true/false)
         */
        'encoding' => true,

        /**
         * Replace deprecated `ereg` regular expression functions with preg.
         * Risky rule: risky if the `ereg` function is overridden
         */
        'ereg_to_preg' => false,

        /**
         * Escape implicit backslashes in strings and heredocs to help understanding which chars
         * are special and interpreted by PHP, and which are not.
         *
         * double_quoted (bool): Whether to fix double-quoted strings (default: true)
         * heredoc_syntax (bool): Whether to fix heredoc syntax (default: true)
         * single_quoted (bool): Whether to fix single-quoted strings (default: false)
         */
        'escape_implicit_backslashes' => array(
            'double_quoted' => true,
            'heredoc_syntax' => true,
            'single_quoted' => false,
        ),

        /**
         * Add curly braces to indirect variables to make them clear to understand.
         * Requires PHP>=7.0
         *
         * (true/false)
         */
        'explicit_indirect_variable' => true,

        /**
         * PHP code must use the long `<?php` tags or short-echo `<?=` tags and NOT other variations.
         *
         * (true/false)
         */
        'full_opening_tag' => true,

        /**
         * Spaces should be properly placed in a function declaration.
         *
         * closure_function_spacing ('none', 'one'): spacing to use before open parentheses for closures
         */
        'function_declaration' => array('closure_function_spacing' => 'one'),

        /**
         * Add missing space between the functions argument and its typehint.
         *
         * (true/false)
         */
        'function_typehint_space' => true,

        /**
         * Add, replace, or remove header comment.
         *
         * commentType ('comment', 'PHPDoc'): comment syntax type
         * header (string): proper header content, required
         * location ('after_declare_strict', 'after_open'): location of the inserted header
         * separate ('both', 'bottom', 'none', 'top'): Whether the header should be separated
         *  from the file content with a new line
         */
        'header_comment' => array(
            'commentType' => 'comment',
            'location' => 'after_declare_strict',
            'separate' => 'bottom',
            'header' => file_get_contents(__DIR__ . '/DefaultFileHeader.txt'),
        ),

        /**
         * Convert `headerdoc` to `nowdoc` where possible.
         *
         * (true/false)
         */
        'heredoc_to_nowdoc' => false,

        /**
         * Include/require and file path should be divided with a single space. File path
         * should not be placed under brackets.
         *
         * (true/false)
         */
        'include' => true,

        /**
         * Pre- or post-increment and decrement operators should be used if possible.
         *
         * style ('post', 'pre'): whether to use pre- or post-increment and decrement operators
         */
        'increment_style' => array('style' => 'post'),

        /**
         * Code MUST use configured indentation type.
         *
         * (true/false)
         */
        'indentation_type' => true,

        /**
         * All PHP files must use same line ending.
         *
         * (true/false)
         */
        'line_ending' => true,

        /**
         * Ensure there is no ocd on the same line as the PHP open tag.
         *
         * (true/false)
         */
        'linebreak_after_opening_tag' => true,

        /**
         * List (array destructuring) assignment should be declared using the configured syntax.
         * Requires PHP>=7.1
         *
         * syntax ('long', 'short'): whether to use the 'long' or 'short' 'list' syntax
         */
        'list_syntax' => array('syntax' => 'long'),

        /**
         * Cast should be written in lower case.
         *
         * (true/false)
         */
        'lowercase_cast' => true,

        /**
         * The PHP constants `true`, `false`, and `null` MUST be in lower case.
         *
         * (true/false)
         */
        'lowercase_constants' => true,

        /**
         * PHP keywords MUST be in lower case.
         *
         * (true/false)
         */
        'lowercase_keywords' => true,

        /**
         * In method arguments and method call, there MUST NOT be a space before each comma
         * and there MUST be one space after each comma. Argument lists MAY be split across
         * multiple lines, where each subsequent line is indented once. When doing so, the
         * first time in the list MUST be on the next line, and there MUST be only one
         * argument per line.
         *
         * ensure_fully_multiline (bool): ensure every argument of a multiline argument list
         *  is on it's own line
         * keep_multiple_spaces_after_comma (bool): keep multiple spaces after each comma
         */
        'method_argument_space' => array(
            'ensure_fully_multiline' => true,
            'keep_multiple_spaces_after_comma' => false,
        ),

        /**
         * Method chaining MUST be properly indented. Method chaining with different levels
         * of indentation is not supported.
         *
         * (true/false)
         */
        'method_chaining_indentation' => true,

        /**
         * DocBlocks must start with two asterisks, multiline comments must start with a single
         * asterisk, after the opening slash. Both must end with a single asterisk before the
         * closing slash.
         */
        'multiline_comment_opening_closing' => true,

        /**
         * Forbid multi-line whitespace before the closing semicolon or move the semicolon to
         * the new line for chained calls.
         *
         * strategy ('new_line_for_chained_calls', 'no_multi_line')
         */
        'multiline_whitespace_before_semicolons' => array('strategy' => 'no_multi_line'),

        /**
         * Function defined by PHP should be called using the correct casing
         */
        'native_function_casing' => true,

        /**
         * All instances created with the new keyword must be followed by braces.
         *
         * (true/false)
         */
        'new_with_braces' => false,

        /**
         * There should be no empty lines after class opening brace.
         *
         * (true/false)
         */
        'no_blank_lines_after_class_opening' => true,

        /**
         * There should not be blank lines between DocBlock and the documented element.
         *
         * (true/false)
         */
        'no_blank_lines_after_phpdoc' => true,

        /**
         * There must be a comment when fall-through is intentional in a non-empty case body.
         *
         * comment_text (string): the test to use in the added comment and to detect it
         */
        'no_break_comment' => array('comment_text' => 'no break'),

        /**
         * The closing `?>` tag MUST be omitted from files containing only PHP.
         *
         * (true/false)
         */
        'no_closing_tag' => true,

        /**
         * There should not be any empty comments.
         *
         * (true/false)
         */
        'no_empty_comment' => true,

        /**
         * There should not be any empty PHPDoc blocks.
         *
         * (true/false)
         */
        'no_empty_phpdoc' => true,

        /**
         * Remove useless semicolon statements.
         *
         * (true/false)
         */
        'no_empty_statement' => true,

        /**
         * Removes extra blank lines and/or blank lines following configuration.
         *
         * tokens (array): list of tokens to fix
         */
        'no_extra_blank_lines' => array('tokens' => array(
            'curly_brace_block',
            'extra',
            'parenthesis_brace_block',
            'square_brace_block',
            'throw',
            'use',
        )),

        /**
         * Remove leading slashes in use clauses.
         *
         * (true/false)
         */
        'no_leading_import_slash' => true,

        /**
         * The namespace declaration line shouldn't contain leading whitespace.
         *
         * (true/false)
         */
        'no_leading_namespace_whitespace' => true,

        /**
         * Either language construct `print` or `echo` should be used.
         *
         * use ('echo', 'print'): the desired language construct
         */
        'no_mixed_echo_print' => array('use' => 'echo'),

        /**
         * Operator `=>` should not be surrounded by multi-line whitespaces.
         *
         * (true/false)
         */
        'no_multiline_whitespace_around_double_arrow' => true,

        /**
         * Properties MUST not be explicitly initialized with `null`.
         *
         * (true/false)
         */
        'no_null_property_initialization' => true,

        /**
         * Short cast `bool` using double exclamation mark should not be used.
         *
         * (true/false)
         */
        'no_short_bool_cast' => true,

        /**
         * Replace short-echo `<?=` with long format `<?php echo` syntax.
         *
         * (true/false)
         */
        'no_short_echo_tag' => true,

        /**
         * Single-line whitespace before closing semicolon are prohibited.
         *
         * (true/false)
         */
        'no_singleline_whitespace_before_semicolons' => true,

        /**
         * When making a method or function call, there MUST NOT be a space between the method
         * or function name and the opening parenthesis.
         *
         * (true/false)
         */
        'no_spaces_after_function_name' => true,

        /**
         * There MUST NOT be spaces around offset braces.
         *
         * positions (array): whether spacing should be fixed inside and/or outside the offset braces
         */
        'no_spaces_around_offset' => array('positions' => array('inside', 'outside')),

        /**
         * There MUST NOT be a space after the opening parenthesis. There MUST NOT be a space
         * before the closing parenthesis.
         *
         * (true/false)
         */
        'no_spaces_inside_parenthesis' => true,

        /**
         * Replaces superfluous `elseif` with `if`.
         *
         * (true/false)
         */
        'no_superfluous_elseif' => true,

        /**
         * Remove trailing commas in list function calls.
         *
         * (true/false)
         */
        'no_trailing_comma_in_list_call' => true,

        /**
         * PHP single-line arrays should not have trailing comma.
         *
         * (true/false)
         */
        'no_trailing_comma_in_singleline_array' => true,

        /**
         * Remove trailing whitespace at the end of non-blank lines.
         *
         * (true/false)
         */
        'no_trailing_whitespace' => true,

        /**
         * There MUST NOT be trailing spaces inside comments and phpdocs.
         *
         * (true/false)
         */
        'no_trailing_whitespace_in_comment' => true,

        /**
         * Removes unneeded parentheses around control statements.
         *
         * statements (array): list of control statements to fix ('break', 'clone',
         *  'continue', 'echo_print', 'return', 'switch_case', 'yield')
         */
        'no_unneeded_control_parentheses' => array('statements' => array(
            'break',
            'clone',
            'continue',
            'echo_print',
            'return',
            'switch_case',
            'yield',
        )),

        /**
         * Removes unneeded curly braces that are superfluous and are not part of
         * a control structures body.
         *
         * (true/false)
         */
        'no_unneeded_curly_braces' => true,

        /**
         * A final class must not have final methods.
         *
         * (true/false)
         */
        'no_unneeded_final_method' => true,

        /**
         * Unused use statements must be removed.
         *
         * (true/false)
         */
        'no_unused_imports' => true,

        /**
         * There should not be useless `else` cases.
         *
         * (true/false)
         */
        'no_useless_else' => true,

        /**
         * There should not be an empty return statement at the end of a function.
         *
         * (true/false)
         */
        'no_useless_return' => true,

        /**
         * In array declaration, there MUST NOT be a whitespace before each comma.
         *
         * (true/false)
         */
        'no_whitespace_before_comma_in_array' => true,

        /**
         * Remove trailing whitespace at the end of blank lines.
         *
         * (true/false)
         */
        'no_whitespace_in_blank_line' => true,

        /**
         * Array index should always be written by using square braces.
         *
         * (true/false)
         */
        'normalize_index_brace' => true,

        /**
         * Logical NOT operators (!) should have leading and trailing whitespaces.
         *
         * (true/false)
         */
        'not_operator_with_space' => false,

        /**
         * Logical NOT operators (!) should have one trailing whitespace.
         *
         * (true/false)
         */
        'not_operator_with_successor_space' => false,

        /**
         * There should not be space before or after object operator (`->`).
         *
         * (true/false)
         */
        'object_operator_without_whitespace' => true,

        /**
         * Orders the elements of classes/interfaces/traits.
         *
         * order (array): list of strings defining order of elements.
         */
        'ordered_class_elements' => array('order' => array(
            'use_trait',
            'constant_public',
            'constant_protected',
            'constant_private',
            'property_public',
            'property_protected',
            'property_private',
            'construct',
            'destruct',
            'magic',
            'phpunit',
            'method_public',
            'method_protected',
            'method_private',
        )),

        /**
         * Ordering use statements.
         *
         * importsOrder (array, `null`): defines order of import types
         * sortAlgorithm ('alpha', 'length'): whether the statements should be sorted
         *  alphabetically or by length
         */
        'ordered_imports' => array(
            'importsOrder' => null,
            'sortAlgorithm' => 'alpha',
        ),

        /**
         * PHPUnit annotations should be FQCNs, including a root namespace.
         *
         * (true/false)
         */
        'php_unit_fqcn_annotation' => true,

        /**
         * There should be one or no space before colon, and one space after it in return
         * type declarations.
         *
         * space_before ('none', 'one'): spacing to apply before colon
         */
        'return_type_declaration' => array('space_before' => 'one'),

        /**
         * Inside class or interface element "self" should be preferred to the class name itself.
         *
         * (true/false)
         */
        'self_accessor' => true,

        /**
         * Instructions must be terminated with a semicolon.
         *
         * (true/false)
         */
        'semicolon_after_instruction' => true,

        /**
         * A return statement wishing to return `void` should not return `null`.
         *
         * (true/false)
         */
        'simplified_null_return' => true,

        /**
         * A PHP file without end tag must always end with a single empty line feed.
         *
         * (true/false)
         */
        'single_blank_line_at_eof' => true,

        /**
         * There should be exactly one blank line before a namespace declaration.
         *
         * (true/false)
         */
        'single_blank_line_before_namespace' => true,

        /**
         * Each namespace use MUST go on its own line and there MUST be one black line after
         * the use statements block.
         *
         * (true/false)
         */
        'single_line_after_imports' => true,

        /**
         * Convert double quotes to single quotes for simple strings.
         *
         * (true/false)
         */
        'single_quote' => true,

        /**
         * Fix whitespace after a semicolon.
         *
         * remove_in_empty_for_expressions (bool): whether spaces should be remove for
         *  empty `for` expressions
         */
        'space_after_semicolon' => array('remove_in_empty_for_expressions' => true),

        /**
         * Replace all `<>` with `!=`.
         *
         * (true/false)
         */
        'standardize_not_equals' => true,

        /**
         * A case should be followed by a colon and not a semicolon.
         *
         * (true/false)
         */
        'switch_case_semicolon_to_colon' => true,

        /**
         * Removes extra spaces between color and case value.
         *
         * (true/false)
         */
        'switch_case_space' => true,

        /**
         * Standardize spaces around ternary operator.
         *
         * (true/false)
         */
        'ternary_operator_spaces' => true,

        /**
         * PHP multi-line arrays should have a trailing comma.
         *
         * (true/false)
         */
        'trailing_comma_in_multiline_array' => true,

        /**
         * Arrays should be formatted like function/method arguments, without leading or
         * trailing single line spaces.
         *
         * (true/false)
         */
        'trim_array_spaces' => true,

        /**
         * Unary operators should be placed adjacent to their operands.
         *
         * (true/false)
         */
        'unary_operator_spaces' => true,

        /**
         * Visibility MUST be declared on all properties and methods; abstract and final
         * MUST be declared before the visibility; static MUST be declared after the
         * visibility.
         *
         * elements (array): the structural elements to fix (PHP >= 7.1 required for `const`)
         */
        'visibility_required' => array('elements' => array(
            'property',
            'method',
        )),

        /**
         * In array declaration, there MUST be a whitespace after each comma.
         *
         * (true/false)
         */
        'whitespace_after_comma_in_array' => true,
    ))
    //->setIndent("\t")
    // ->setLineEnding("\r\n");
;
