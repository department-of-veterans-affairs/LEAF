
<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link href="{{ asset('css/app.css') }}" rel="stylesheet">
        <title>LEAF Test</title>
    </head>

    <body>
        <div class="container">
            <div class="row">
                <div class="col">
                    <h1>New Record</h1>
                </div>
            </div>

            <div class="row">
                <div class="col">
                    <form method="POST" action="{{ route('request.store', $visn) }}">
                        @csrf
                        <div class="form-group">
                            <label for="title">Title</label>
                            <input type="text" class="form-control" id="title" name="title" />
                        </div>
                        <div class="form-group">
                            <label for="numform_5807b">Form</label>
                            <input type="text" class="form-control" id="numform_5807b" name="numform_5908b" value="1" />
                        </div>

                        <button type="submit" class="btn btn-primary">Submit</button>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>