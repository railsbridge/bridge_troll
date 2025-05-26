export default {
  srcDir: ".",
  srcFiles: [
    "spec/javascripts/helpers/whenReady.js",
    "public/assets/application-*.js",
    "public/assets/section_organizer-*.js",
  ],
  specDir: ".",
  specFiles: ["spec/javascripts/**/*[sS]pec.?(m)js"],
  helpers: [
    "node_modules/sinon/pkg/sinon.js",
    "node_modules/jasmine-jquery/lib/jasmine-jquery.js",
    "spec/javascripts/helpers/**/*.?(m)js",
  ],
  env: {
    stopSpecOnExpectationFailure: false,
    stopOnSpecFailure: false,
    random: true,
    // Fail if a suite contains multiple suites or specs with the same name.
    forbidDuplicateNames: true,
  },

  // For security, listen only to localhost. You can also specify a different
  // hostname or IP address, or remove the property or set it to "*" to listen
  // to all network interfaces.
  listenAddress: "localhost",

  // The hostname that the browser will use to connect to the server.
  hostname: "localhost",

  browser: {
    name: "headlessChrome",
  },
};
