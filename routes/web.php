<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

Route::get('/login', function () {
    return view('login');
});

Route::get('/welcome', function () {
    return view('welcome');
});

Route::get('/test/{param?}', function ($param = null) {

    return view('subdirectory/subexample', ['param' => $param]);
});