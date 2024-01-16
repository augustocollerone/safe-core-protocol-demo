import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import Home from "./routes/home/Home";
import reportWebVitals from "./reportWebVitals";
import { createHashRouter, RouterProvider } from "react-router-dom";
import PluginList from "./routes/plugins/PluginList";
import { WhitelistPlugin } from "./routes/samples/relay/WhitelistPlugin";
import { ApiKeyAccountPluggin } from "./routes/samples/relay/ApiKeyAccountPluggin";

const router = createHashRouter([
  {
    path: "/",
    index: true,
    element: <Home />,
    errorElement: <Home />,
  },
  {
    path: "/plugins",
    element: <PluginList />,
  },
  {
    path: "/relay/:pluginAddress",
    element: <WhitelistPlugin />,
  },
  {
    path: "/apiKeyAccounts/:pluginAddress",
    element: <ApiKeyAccountPluggin />,
  },
]);

const root = ReactDOM.createRoot(
  document.getElementById("root") as HTMLElement
);
root.render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
