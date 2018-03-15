const XSSHelpers = require('../../../../libs/js/LEAF/XSSHelpers.js');

test('containsTag()', () => {
    var input = "This <strong>is</strong> <a href='#'>input</a>";
    var tags = ['<a>', '<strong>'];

    expect(XSSHelpers.containsTag(input, "b")).toBe(false);
    expect(XSSHelpers.containsTag(input, "<  a >")).toBe(true);
    expect(XSSHelpers.containsTag(input, "</strong>")).toBe(true);
});

test('containsTags()', () => {
    var input = "This <strong>is</strong> <a href='#'>input</a>";

    expect(XSSHelpers.containsTags(input, ["b"])).toBe(false);
    expect(XSSHelpers.containsTags(input, ["strong", "div"])).toBe(true);
    expect(XSSHelpers.containsTags(input, ["strong", "div"], false)).toBe(true);
    expect(XSSHelpers.containsTags(input, ["strong", "div"], true)).toBe(false);
    expect(XSSHelpers.containsTags(input, ["<a>"])).toBe(true);
    expect(XSSHelpers.containsTags(input, ["strong"])).toBe(true);
    expect(XSSHelpers.containsTags(input, ["<strong>", "a"])).toBe(true);
});

test('stripAllTags()', () => {
    var input = "This <strong>is</strong> <a href='#'>input</a> <script lang='javascript'>alert('hi')</script>";
    var output = "This is input alert('hi')";

    expect(XSSHelpers.stripAllTags(input)).toBe(output);
});

test('stripTag()', () => {
    var input = "This <strong>is</strong> <a href='#'>input</a> <script lang='javascript'>alert('hi')</script>";
    var output = "This <strong>is</strong> <a href='#'>input</a> alert('hi')";
    var tags = ['<script>'];

    expect(XSSHelpers.stripTag(input, "script")).toBe(output);
});

test('stripTags()', () => {
    var input = "This <strong>is</strong> <a href='#'>input</a> <script lang='javascript'>alert('hi')</script>";
    var output = "This is input alert('hi')";
    var tags = ["script", "<strong>", "a"];

    expect(XSSHelpers.stripTags(input, tags)).toBe(output);
});

