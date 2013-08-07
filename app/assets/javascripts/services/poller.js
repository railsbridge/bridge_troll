Bridgetroll.Services.Poller = function (options) {
  var obj = _.extend(this, {
    pollUrl: options.pollUrl,
    afterPoll: options.afterPoll,

    suspended: false,
    pollTimer: null,

    polling: function () {
      return !!this.pollTimer;
    },

    startPolling: function (interval) {
      interval = interval || this.pollingInterval;
      var refreshData = _.bind(function () {
        $.ajax({
          url: this.pollUrl,
          success: _.bind(function (json) {
            if (!this.suspended) {
              this.pollsSinceLastIntervalReset += 1;
              this.afterPoll(json);
            }
            this.pollTimer = setTimeout(refreshData, this.pollingInterval * 1000);
            this.computeNewPollingInterval();
          }, this)
        });
      }, this);
      this.pollTimer = setTimeout(refreshData, interval * 1000);
    },

    stopPolling: function () {
      clearTimeout(this.pollTimer);
      this.pollTimer = undefined;
    },

    togglePolling: function () {
      if (this.polling()) {
        this.stopPolling();
      } else {
        this.startPolling();
      }
    },

    stallPolling: function () {
      if (this.pollTimer) {
        clearTimeout(this.pollTimer);
        this.startPolling(5);
      }
    },

    suspendPolling: function () {
      this.suspended = true;
    },

    resumePolling: function () {
      this.suspended = false;
    },

    computeNewPollingInterval: function () {
      var intervals = [2, 5, 15, 30, 60];
      if (this.pollsSinceLastIntervalReset > 5) {
        var existingIntervalIndex = intervals.indexOf(this.pollingInterval);
        if (existingIntervalIndex < intervals.length - 1) {
          this.pollsSinceLastIntervalReset = 0;
          this.pollingInterval = intervals[existingIntervalIndex + 1];
        }
      }
    },

    resetPollingInterval: function () {
      this.pollsSinceLastIntervalReset = 0;
      this.pollingInterval = 1;
    }
  });
  obj.resetPollingInterval();
  return obj;
};