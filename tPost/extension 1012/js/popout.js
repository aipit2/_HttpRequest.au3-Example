const btnLoginMuaban = document.getElementById("btnLoginMuaban");
document.querySelector("#btnLoginMuaban").addEventListener('click', function() {
  // check href
  chrome.tabs.query({currentWindow: true,active: true}, function(tabs) {
      var currentUrl = tabs[0].url;
      if (currentUrl.search("muaban.net") == -1) {
          chrome.tabs.update({
              url: "https://muaban.net"
          });
      } else {
        chrome.scripting.executeScript({
            target: {tabId: tabs[0].id},
            function: loginMuaban
        })
      }
  });
});

document.querySelector("#btnLoginBds").addEventListener('click', function() {
    // check href
    chrome.tabs.query({currentWindow: true,active: true}, function(tabs) {
        var currentUrl = tabs[0].url;
        if (currentUrl.search("batdongsan.com.vn") == -1) {
            chrome.tabs.update({
                url: "https://batdongsan.com.vn/"
            });
        } else {
          chrome.scripting.executeScript({
              target: {tabId: tabs[0].id},
              function: getAccessTokenBds
          })
        }
    });
  });

function getAccessTokenBds(){
  var cookie = encodeURIComponent(document.cookie)
  if(cookie != ""){
    var data = "site=Batdongsan.com.vn&data=" + cookie
    fetch("http://127.0.0.1:3000/LOGIN", {
    "headers": {
      "accept": "application/json, text/plain, */*",
      "accept-language": "en-US,en;q=0.9",
      "sec-ch-ua": "\"Not?A_Brand\";v=\"8\", \"Chromium\";v=\"108\", \"Microsoft Edge\";v=\"108\"",
      "sec-ch-ua-mobile": "?0",
      "sec-ch-ua-platform": "\"Windows\"",
      "sec-fetch-dest": "empty",
      "sec-fetch-mode": "no-cors",
      "sec-fetch-site": "same-origin"
    },
    "referrerPolicy": "strict-origin-when-cross-origin",
    "body": data,
    "method": "POST",
    "mode": "no-cors",
    "credentials": "include"
  });
  }else{
    console.log("Đéo tìm thấy cookie");
  }
}

function loginMuaban(){
    console.log("LOGIN MUABAN");
    var token = window.localStorage.getItem("token");
    navigator.clipboard.writeText(token);
    alert('Đã copy, xin vui lòng dán dữ liệu vào ô cookie tại phần mềm tPost');
}
