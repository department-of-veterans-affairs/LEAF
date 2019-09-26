<!doctype html>
<html>
<head>
    @include('includes.head')
</head>
<body>
<div class="leaf-app">

    <header class="usa-header usa-header-extended" role="banner">
        @include('includes.header')
    </header>

    <div class="usa-overlay"></div>
    <div id="main-content">

            @yield('content')

    </div>

    <footer class="position-relative">
        @include('includes.footer')
    </footer>

</div>
  <script src="{{ asset('js/app.js') }}"></script>
</body>
</html>
