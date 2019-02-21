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
            Route::delete('/{requestId}', 'RequestsController@delete')->name('request.delete');

            Route::post('/{requestId}/restore', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/form', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/form/json', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/form/add/{categoryID}', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/form/update/{categoryIDS}', 'RequestsController@getById')->name('request.detail');//TODO

            Route::post('/{requestId}/bookmark', 'RequestsController@getById')->name('request.detail');//TODO
            Route::delete('/{requestId}/bookmark', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/data', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/dataforsigning', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/initiator/{initiator}', 'RequestsController@getById')->name('request.detail');//TODO

            Route::get('/{requestId}/progress', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/progress/json', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/recordinfo', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/service/{serviceID}', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/submit', 'RequestsController@getById')->name('request.detail');//TODO

            Route::get('/{requestId}/tags', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/tags/{tagsInput}', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/title/{title}', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/action/last', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/action/{actionType}', 'RequestsController@getById')->name('request.detail');//TODO

            Route::get('/{requestId}/step', 'RequestsController@getById')->name('request.detail');//TODO
            Route::post('/{requestId}/step/{stepID}', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/indicator/format/{formats}', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/indicator/byworkflow', 'RequestsController@getById')->name('request.detail');//TODO
            Route::delete('/{requestId}/indicator/{indicatorID}/attachment', 'RequestsController@getById')->name('request.detail');//TODO

            Route::get('/{requestId}/indicator/{indicatorID}/history', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/indicator/{indicatorID}/raw/{parseTemplate}', 'RequestsController@getById')->name('request.detail');//TODO
            Route::get('/{requestId}/indicator/{indicatorID_list}/customData', 'RequestsController@getById')->name('request.detail');//TODO

            Route::post('/{requestId}/indicator/{indicatorId}', 'RequestsController@updateIndicator');
        });
    });
});
