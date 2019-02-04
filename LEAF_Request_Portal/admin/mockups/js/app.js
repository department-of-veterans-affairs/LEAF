Vue.component('line-chart', {
  extends: VueChartJs.Line,
  mounted () {
    this.renderChart({
      labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July'],
      datasets: [
        {
          label: 'Data One',
          backgroundColor: '#f87979',
          data: [40, 39, 10, 40, 39, 80, 40]
        }
      ]
    }, {responsive: true, maintainAspectRatio: false})
  }

});


var app = new Vue({
  // app initial state
  el: '.leaf-app',
  data: {
    isShowing:false,
    displayCreateFormModal: false
  },
  methods: {
    showAlert: function(event){
      alert('How can I help you!');
    },
    showCreateFormModal: function(){
      this.displayCreateFormModal = !this.displayCreateFormModal;
    }
  }
});
