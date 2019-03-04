<div class="usa-navbar">
  <div class="navbar-brand">
      <img src="{{ asset('images/VA-logo.png') }}" class="logo" alt="valogo">
      <a href="#" title="Home"aria-label="Home">VA</a>
      <span class="vertical-divider"></span>
      <a href="#" title="NAVAHCS LEAF Site" aria-label="NAVAHCS LEAF Site">
         NAVAHCS LEAF Site <span class="sub-title">Prescott, Arizona</span>
      </a>
  </div>
  <button class="usa-menu-btn">Menu</button>
</div>

  <nav role="navigation" class="usa-nav">
      <div class="usa-nav-inner">
        <button class="usa-nav-close">
          <i class="fas fa-times"></i>
        </button>
        <div class="usa-nav-secondary">
          <ul class="usa-nav-primary usa-accordion">

            <li>
              <a href="#" class="usa-nav-link">
                <span>Home</span>
              </a>
            </li>

            <li>
              <a href="#" class="usa-nav-link">
                <span>Admin</span>
              </a>
            </li>
            <li><button class="usa-accordion-button usa-nav-link" aria-expanded="false" aria-controls="extended-nav-section-one">
              <span>User: Dastan R</span>
            </button>
            <ul id="extended-nav-section-one" class="usa-nav-submenu">
              <li>
                  <a href="#">Settings</a>
                </li><li>
                  <a href="#">Profile</a>
                </li><li>
                  <a href="#">Logout</a>
                </li>
              </ul>
            </li>
            <li><a class="usa-nav-link btn-help" href="#">
                <span><i class="fas fa-question"></i> LEAF Help</span></a>
            </li>

          </ul>
      </div>
  </div>
</nav>
