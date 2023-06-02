//for sending a message
// chrome.runtime.sendMessage({greeting: "hello"}, function(response) {

// });

//for listening any message which comes from runtime
chrome.runtime.onMessage.addListener(messageReceived);

function messageReceived(msg) {
    console.log(msg);
    switch(msg.msg) {
        case "getToken":
            console.log("Người dùng muốn getToken");
            getToken();
            break;
        default:
            console.log("Đã nhận được message: " + msg.msg);
    }
}
function getToken(){
    
}