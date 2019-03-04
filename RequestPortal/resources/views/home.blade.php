@extends('layouts.default')
@section('title', 'Home')

@section('content')
<div class="conatiner">
  <div class="row">
    <div class="col-8 col-sm-12 col-md-10 col-lg-10">
      <div class="row">
        <div class="col-8 col-sm-12 col-md-6 col-lg-6">
          <div class="row">
            <div class="col-sm-4">
              <button class="usa-button leaf-btn leaf-btn-green"><i class="fas fa-plus"></i> Create Request</button>
            </div>
            <div class="col-sm-4">
              <button class="usa-button leaf-btn ml-n5"><i class="fas fa-file"></i> Report Builder</button>
           </div>
         </div>
         <div class="inbox-form">
           <div class="row">
               <div class="col-sm-4">
                   <form class="usa-form">
                    <select name="inbox-options" id="inbox-options">
                      <option value>Inbox (14)</option>
                      <option value="value1">Option A</option>
                      <option value="value2">Option B</option>
                      <option value="value3">Option C</option>
                    </select>
                  </form>
              </div>
              <div class="col-sm-5">
                <a href="#" class="inbox-link">Open Inbox <i class="fas fa-external-link-alt"></i></a>
              </div>
            </div>
         </div>
       </div>
       <div class="col-8 col-sm-12 col-md-3 col-lg-3 offset-lg-3">
         <div class="search-box mt-5">
           <a href="/#">Advanced Search</a>
           <form>
             <input id="search" name="search" type="text" placeholder="Search...">
             <button class="usa-button leaf-btn search-btn"><i class="fas fa-search"></i></button>
           </form>
         </div>
       </div>
    </div>
    <div class="inbox-table mt-n5">
      <table>
        <caption>Inbox</caption>
        <thead>
          <tr>
            <th scope="col" class="w-15">Date</th>
            <th scope="col" class="w-25">Site/Project</th>
            <th scope="col" class="w-25">Request</th>
            <th scope="col" class="w-10">Status</th>
            <th scope="col" class="w-10">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th scope="row">Tue 10 Oct 2019</th>
            <td>VAHAACOS Tracking System</td>
            <td><a href="#">Approval of Example Form</a></td>
            <td>Pending</td>
            <td><a href="#"><i class="fas fa-check-square"> Approve</a></td>
          </tr>

          <tr>
            <th scope="row">Tue 10 Oct 2019</th>
            <td>VAHAACOS Tracking System</td>
            <td><a href="#">Approval of Example Form</a></td>
            <td>Pending</td>
            <td><a href="#"><i class="fas fa-check-square"> Approve</a></td>
          </tr>

          <tr>
            <th scope="row">Tue 10 Oct 2019</th>
            <td>VAHAACOS Tracking System</td>
            <td><a href="#">Approval of Example Form</a></td>
            <td>Pending</td>
            <td><a href="#"><i class="fas fa-check-square"> Approve</a></td>
          </tr>

          <tr>
            <th scope="row">Tue 10 Oct 2019</th>
            <td>VAHAACOS Tracking System</td>
            <td><a href="#">Approval of Example Form</a></td>
            <td>Pending</td>
            <td><a href="#"><i class="fas fa-check-square"> Approve</a></td>
          </tr>

          <tr>
            <th scope="row">Tue 10 Oct 2019</th>
            <td>VAHAACOS Tracking System</td>
            <td><a href="#">Approval of Example Form</a></td>
            <td>Pending</td>
            <td><a href="#"><i class="fas fa-check-square"> Approve</a></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <div class="col col-sm-12 col-md-12 col-lg-2">
    <div class="facility-news">
      <h4>Facility News</h4>
      <a href="">Sample Item Link</a>
      <p>Text for sample item</p>

      <a href="">Additional Sample Link</a>
      <p>Text for Additional sample item</p>

      <a href="">Updated information for ABC</a>
      <p>Updated information</p>

      <h3>Register for Event</h3>
      <p>Event information</p>

      <button class="usa-button leaf-btn">Sign Up</button>
      </div>
      <div class="recent-activity mt-5 mb-5">
        <h4>Recent Activity</h4>
        <p>Area for items that may be of intrest to LEAF users based on their recent acitivty.</p>

        <a href="#">Recent Used Link One</a>
        <p>Recent Link description</p>
        <a href="#">Suggested Link</a>
        </div>
  </div>
</div>
</div>
@stop
