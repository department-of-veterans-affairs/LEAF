<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link href="{{ asset('css/app.css') }}" rel="stylesheet">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script>
            function deleteRequest(url)
            {
                $.ajax({
                    type: 'DELETE',
                    url: url,
                    data: { '_token':'{{ csrf_token() }}' },
                    cache: false
                }).done(function(data) {
                    location.reload();
                }).fail(function (jqXHR, error, errorThrown) {
                    console.log(jqXHR);
                    console.log(error);
                    console.log(errorThrown);
                }).always(function () {

                });
            }
            function restoreRequest(url)
            {
                $.ajax({
                    type: 'POST',
                    url: url,
                    data: { '_token':'{{ csrf_token() }}' },
                    cache: false
                }).done(function(data) {
                    location.reload();
                }).fail(function (jqXHR, error, errorThrown) {
                    console.log(jqXHR);
                    console.log(error);
                    console.log(errorThrown);
                }).always(function () {

                });
            }
        </script>
        <title>LEAF Test</title>
    </head>

    <body>
        <div class="container-fluid">
            <div class="row">
                <div class="col">
                    <h1>Records</h1>
                </div>
                <div class="col text-right">
                    <a href="{{ route('request.create', $visn) }}">New Request</a>
                </div>
            </div>

            <div class="row">
                <div class="col">
                    <table class="table">
                        <thead>
                            <th>id</th>
                            <th>date</th>
                            <th>service</th>
                            <th>user</th>
                            <th>title</th>
                            <th>priority</th>
                            <th>last status</th>
                            <th>submitted</th>
                            <th>deleted</th>
                            <th>is writable user</th>
                            <th>is writable group</th>
                            <th>delete/restore</th>
                        </thead>
                        <tbody>
                            @foreach ($records as $record)
                                <tr>
                                    <td>{{ $record->recordID }}</td>
                                    <td>{{ $record->date}}</td>
                                    <td>{{ $record->serviceID }}</td>
                                    <td>{{ $record->userID }}</td>
                                    <td>{{ $record->title }}</td>
                                    <td>{{ $record->priority}}</td>
                                    <td>{{ $record->lastStatus}}</td>
                                    <td>{{ $record->submitted}}</td>
                                    <td>{{ $record->deleted}}</td>
                                    <td>{{ $record->isWritableUser}}</td>
                                    <td>{{ $record->isWritableGroup}}</td>
                                    @if ($record->deleted == 0)
                                        <td>
                                            <button onclick="deleteRequest('{{ route('request.delete', [$visn,$record->recordID]) }}');">
                                                Delete
                                            </button>
                                        </td>
                                    @else
                                        <td>
                                            <button onclick="restoreRequest('{{ route('request.restore', [$visn,$record->recordID]) }}');">
                                                Restore
                                            </button>
                                        </td>
                                    @endif
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </body>
</html>