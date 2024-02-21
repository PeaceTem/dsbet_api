// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"





let Hooks = {}
Hooks.chart = {
  mounted() {
        console.log("The HOok is working!");
        var dps = [{x: 1, y: 10}, {x: 2, y: 13}, {x: 3, y: 18}, {x: 4, y: 20}, {x: 5, y: 17},{x: 6, y: 10}, {x: 7, y: 13}, {x: 8, y: 18}, {x: 9, y: 20}, {x: 10, y: 17}];   //dataPoints. 

        var chart = new CanvasJS.Chart("chartContainer",{
            title :{
                text: "Live Data"
            },
            axisX: {						
                title: "Axis X Title"
            },
            axisY: {						
                title: "Units"
            },
            data: [{
                type: "line",
                dataPoints : dps
            }]
        });

        chart.render();
        var xVal = dps.length + 1;
        var yVal = 15;	
        var updateInterval = 1000;

        var updateChart = function () {


            yVal = yVal +  Math.round(5 + Math.random() *(-5-5));
            dps.push({x: xVal,y: yVal});

            xVal++;
            if (dps.length >  10 )
            {
                dps.shift();				
            }

            chart.render();		

      // update chart after specified time. 

    };

    setInterval(function(){updateChart()}, updateInterval); 
  },
  updated() {
    console.log("The HOok is working!");
}
}



let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => {
    topbar.hide()

}
)

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket




