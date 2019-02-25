<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Illuminate\Support\Facades\Route;

Route::middleware('IsAuth')->group(function () {
    Route::group(array(
        'prefix' => '{visn}',
        'where' => array('visn' => '^(?!api).+'),
    ), function () {
        Route::get('/debug', 'RequestsController@debug')->name('request.debug');
        Route::group(array(
            'prefix' => '/requests',
        ), function () {
            Route::get('/', 'RequestsController@getAll')->name('request.show');
            Route::get('/create', 'RequestsController@create')->name('request.create');
            Route::get('/{requestID}', 'RequestsController@getById')->name('request.detail');

            
        });
    });
});
