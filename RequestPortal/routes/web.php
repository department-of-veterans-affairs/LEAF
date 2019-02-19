<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Illuminate\Support\Facades\Route;

Route::middleware('IsAuth')->group(function () {

    Route::group([
        'prefix' => '{visn}',
        'where' => ['visn' => '^(?!api).+'],
    ], function () {

        Route::group([
            'prefix' => '/requests',
        ], function () {

            Route::get('/', 'RequestsController@getAll')->name('request.show');
            Route::post('/new', 'RequestsController@store')->name('request.store');
            Route::get('/create', 'RequestsController@create')->name('request.create');

            Route::get('/{requestId}', 'RequestsController@getById')->name('request.detail');
            Route::post('/{requestId}/indicator/{indicatorId}', 'RequestsController@updateIndicator');
        });
    });
});