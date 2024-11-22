<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Characters</title>
    <script type="module" crossorigin src="./embedded.BlHoW5LY.js"></script>
    <link rel="modulepreload" crossorigin href="./assets/inspectorTab-7GHnKvSD.js">
    <link rel="modulepreload" crossorigin href="./assets/workbench-DPQnTHYP.js">
    <link rel="stylesheet" crossorigin href="./inspectorTab.DLjBDrQR.css">
    <link rel="stylesheet" crossorigin href="./workbench.D3JVcA9K.css">
    <link rel="stylesheet" crossorigin href="./embedded.w7WN2u1R.css">
  </head>
  <body>
    <div id="root">
    <?php
    // Define the start and end Unicode code points for the desired range
    $startCode = 0; // U+0000 (null) - first Unicode code point
    $endCode = 128512; // U+FFFF (high surrogate) - last Unicode code point
for($i=0x00; $i<= 0x10; $i++){
echo $i.'<br>';
}
    for ($codePoint = $startCode; $codePoint <= $endCode; $codePoint++) {
        $unicodeChar = mb_chr($codePoint);
        echo "U+".dechex($codePoint).": $unicodeChar\n";
    }
    ?>
    </div>
  </body>
</html>

