<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Illuminate\Support\Facades\Route;

Route::middleware('IsAuth')->group(function () {
    Route::group(array(
        'prefix' => '{visn}',
    ), function () {
        Route::group(array(
            'prefix' => '/requests',
        ), function () {
            Route::post('/new', 'RequestsController@store')->name('request.store');
            Route::group(array(
                'prefix' => '/{requestID}',
            ), function () {
                Route::delete('/', 'RequestsController@delete')->name('request.delete');
                Route::post('/restore', 'RequestsController@restore')->name('request.restore');
                Route::get('/form', 'RequestsController@getById')->name('request.form');
                Route::get('/form/json', 'RequestsController@getById')->name('request.form.json');
                /*Route::post('/form/add/{categoryID}', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::post('/form/update/{categoryIDS}', 'RequestsController@getById')->name('request.detail'); //TODO

                Route::post('/bookmark', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::delete('/bookmark', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/data', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/dataforsigning', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::post('/initiator/{initiator}', 'RequestsController@getById')->name('request.detail'); //TODO

                Route::get('/progress', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/progress/json', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/recordinfo', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::post('/service/{serviceID}', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::post('/submit', 'RequestsController@getById')->name('request.detail'); //TODO

                Route::get('/tags', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::post('/tags/{tagsInput}', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::post('/title/{title}', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/action/last', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/action/{actionType}', 'RequestsController@getById')->name('request.detail'); //TODO

                Route::get('/step', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::post('/step/{stepID}', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/indicator/format/{formats}', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/indicator/byworkflow', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::delete('/indicator/{indicatorID}/attachment', 'RequestsController@getById')->name('request.detail'); //TODO

                Route::get('/indicator/{indicatorID}/history', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/indicator/{indicatorID}/raw/{parseTemplate}', 'RequestsController@getById')->name('request.detail'); //TODO
                Route::get('/indicator/{indicatorID_list}/customData', 'RequestsController@getById')->name('request.detail'); //TODO*/

                Route::post('/indicator/{indicatorID}', 'RequestsController@updateIndicator');
            });
        });
    });
});
