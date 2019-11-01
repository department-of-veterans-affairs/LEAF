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
            Route::get('/test', 'RequestsController@test')->name('request.test');
            Route::middleware('RemoveVisn')->group(function () {
                Route::group(array(
                    'prefix' => '/{requestID}',
                ), function () {
                    Route::delete('/', 'RequestsController@delete')->name('request.delete');
                    Route::post('/restore', 'RequestsController@restore')->name('request.restore');
                    Route::get('/form', 'RequestsController@getForm')->name('request.form');
                    Route::get('/form/json', 'RequestsController@getFormJson')->name('request.form.json');
                    Route::post('/form/add/{categoryID}', 'RequestsController@addToCategoryCount')->name('request.form.add'); 
                    Route::post('/form/update', 'RequestsController@switchCategoryCount')->name('request.form.update');

                    Route::post('/bookmark', 'RequestsController@addBookmark')->name('request.bookmark.add'); 
                    Route::delete('/bookmark', 'RequestsController@deleteBookmark')->name('request.bookmark.delete');
                    Route::get('/data', 'RequestsController@getFullFormData')->name('request.data'); 
                    Route::get('/dataforsigning', 'RequestsController@getFullFormDataForSigning')->name('request.data.signing');
                    Route::get('/initiator/{initiator}', 'RequestsController@setInitiator')->name('request.initiator.set'); //TODO

                    

                    Route::get('/progress', 'RequestsController@getProgress')->name('request.progress');
                    Route::get('/progress/json', 'RequestsController@getProgress')->name('request.progress.json');
                    Route::get('/step', 'RequestsController@getCurrentSteps')->name('request.step'); //TODO
                    Route::post('/step/{stepID}', 'RequestsController@getById')->name('request.setstep'); //TODO

                    /*Route::get('/recordinfo', 'RequestsController@getById')->name('request.detail'); //TODO
                    Route::post('/service/{serviceID}', 'RequestsController@getById')->name('request.detail'); //TODO
                    Route::post('/submit', 'RequestsController@getById')->name('request.detail'); //TODO

                    Route::get('/tags', 'RequestsController@getById')->name('request.detail'); //TODO
                    Route::post('/tags/{tagsInput}', 'RequestsController@getById')->name('request.detail'); //TODO
                    Route::post('/title/{title}', 'RequestsController@getById')->name('request.detail'); //TODO
                    Route::get('/action/last', 'RequestsController@getById')->name('request.detail'); //TODO
                    Route::get('/action/{actionType}', 'RequestsController@getById')->name('request.detail'); //TODO

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
        Route::group(array(
            'prefix' => '/form',
        ), function () {
            Route::get('/', 'FormController@getAllForms')->name('form.getAll');
            //Route::post('/new', 'FormController@createForm')->name('form.new');TODO
        });
    });
});
