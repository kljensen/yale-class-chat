// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// import css from "../css/app.css"

import css from "../css/main.scss"
import flatpickrcss from "../node_modules/flatpickr/dist/flatpickr.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

// Enable Phoenix LiveView
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"
import flatpickr from "flatpickr"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } });
liveSocket.connect()

flatpickr('input[type="datetime-local"]', {
  enableTime: true,
  dateFormat: "Y-m-d h:i K",
});