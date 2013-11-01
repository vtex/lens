(function() {
  $(document).ready(function() {
    return chrome.tabs.query({
      active: true,
      currentWindow: true
    }, function(tabs) {
      var a, changeVtexEnv, getSiteName, refresh, tab, updateSiteName;
      tab = tabs[0];
      a = document.createElement("a");
      a.href = tab.url;
      updateSiteName = function(siteName) {
        var parts;
        if (siteName == null) {
          siteName = null;
        }
        if (siteName === null) {
          if (/vtexcommerce/.test(a.hostname)) {
            parts = a.hostname.split('.');
            siteName = (parts[0] === "www" ? parts[1] : parts[0]);
          } else if (typeof jsnomeSite !== "undefined" && jsnomeSite !== null) {
            siteName = jsnomeSite;
          } else {
            parts = a.hostname.split('.');
            siteName = (parts[0] === "www" ? parts[1] : parts[0]);
          }
        }
        return $('#env').data('siteName', siteName);
      };
      getSiteName = function() {
        return $("#env").data('siteName');
      };
      changeVtexEnv = function(env, callback) {
        var siteName, url;
        siteName = getSiteName();
        url = a.protocol + "//" + siteName + "." + env + ".com.br" + a.pathname + a.search + a.hash;
        chrome.tabs.update(tab.id, {
          url: url
        });
        return callback();
      };
      refresh = function() {
        var _ref;
        if ((_ref = getSiteName()) === '' || _ref === null || _ref === (void 0)) {
          $('#env a').addClass('pure-button-disabled');
        } else {
          $('#env a').removeClass('pure-button-disabled');
        }
        return chrome.cookies.getAll({
          url: tab.url
        }, function(cookies) {
          var cookiesObj, section;
          section = $('#cookies');
          cookiesObj = {};
          cookies.forEach(function(c) {
            return cookiesObj[c.name] = c;
          });
          return section.find('li').each(function(i, el) {
            var id, name, status, _ref1;
            name = $(el).data('cookieName');
            id = $(el).attr('id');
            status = section.find('#' + id).find('.status').removeClass('enabled disabled unknown');
            switch ((_ref1 = cookiesObj[name]) != null ? _ref1.value : void 0) {
              case 1:
              case "1":
              case "Value=1":
                return status.text('disabled').addClass('disabled');
              default:
                return status.text('enabled').addClass('enabled');
            }
          });
        });
      };
      $(".env-change").on("click", function() {
        if (!$(this).hasClass('pure-button-disabled')) {
          return changeVtexEnv($(this).data("env"), function() {
            return window.close();
          });
        }
      });
      $('#cookies .action').on('click', function() {
        var name, value;
        value = $(this).hasClass('enable') ? 'Value=0' : 'Value=1';
        name = $(this).closest('.cookie').data('cookieName');
        chrome.cookies.set({
          url: tab.url,
          name: name,
          value: value,
          expirationDate: moment().add('days', 7).unix()
        });
        return refresh();
      });
      updateSiteName();
      return refresh();
    });
  });

}).call(this);
