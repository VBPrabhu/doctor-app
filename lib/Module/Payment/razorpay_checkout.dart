import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/Module/Orders/order_success_page.dart';

class RazorpayCheckout extends StatefulWidget {
  final double totalAmount;
  final String razorpayUrl;
  final Function? onPaymentSuccess;
  final Function? onPaymentFailure;

  const RazorpayCheckout({
    Key? key,
    required this.totalAmount,
    this.razorpayUrl = 'https://rzp.io/rzp/N8Wx4GQ', // Default to the confirmed working URL
    this.onPaymentSuccess,
    this.onPaymentFailure,
  }) : super(key: key);

  @override
  _RazorpayCheckoutState createState() => _RazorpayCheckoutState();
}

class _RazorpayCheckoutState extends State<RazorpayCheckout> {
  bool isLoading = true;
  bool paymentComplete = false;
  String? orderId;

  // This is the HTML content that will load the Razorpay payment button
  // Timer to force close WebView after a period of inactivity following payment attempt
  Timer? _forceCloseTimer;
  
  // Force close timer duration - 120 seconds after payment attempt (longer to prevent false failures)
  // Increased to give more time for payment completion
  final int _forceCloseTimerDuration = 180;
  
  String get razorpayHtml => '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Razorpay Payment</title>
      <style>
        body {
          margin: 0;
          padding: 20px;
          font-family: Arial, sans-serif;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          min-height: 100vh;
          background-color: #f5f5f5;
        }
        .container {
          background-color: white;
          padding: 20px;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
          width: 100%;
          max-width: 500px;
          text-align: center;
        }
        h2 {
          color: #333;
          margin-bottom: 20px;
        }
        .amount {
          font-size: 24px;
          font-weight: bold;
          color: #333;
          margin: 20px 0;
        }
        .razorpay-embed-btn {
          margin-top: 20px;
        }
        #payment-status {
          margin-top: 20px;
          padding: 10px;
          border-radius: 4px;
          display: none;
        }
        .success {
          background-color: #d4edda;
          color: #155724;
          border: 1px solid #c3e6cb;
        }
        .failure {
          background-color: #f8d7da;
          color: #721c24;
          border: 1px solid #f5c6cb;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>Complete Your Payment</h2>
        <div class="amount">Total: ₹${widget.totalAmount.toStringAsFixed(2)}</div>
        <div id="payment-status"></div>
        <div class="razorpay-embed-btn" data-url="${widget.razorpayUrl}" data-text="Pay Now" data-color="#528FF0" data-size="medium">
          <script>
            // Function to notify Flutter about payment events
            function notifyFlutter(event, data) {
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler(event, data);
              } else {
                // For standard WebView
                // Use string concatenation instead of interpolation for JavaScript
                window.webkit?.messageHandlers?.[event]?.postMessage(data);
                window[event]?.postMessage(data);
              }
              
              // Set a flag in localStorage to indicate payment completion
              if (event === 'paymentSuccess' || event === 'paymentFailure') {
                localStorage.setItem('payment_status', event);
                localStorage.setItem('payment_data', JSON.stringify(data));
                
                // Display status on page
                const statusDiv = document.getElementById('payment-status');
                statusDiv.style.display = 'block';
                
                if (event === 'paymentSuccess') {
                  statusDiv.className = 'success';
                  statusDiv.innerText = 'Payment successful! Redirecting...';
                  
                  // Redirect to a success URL to trigger detection
                  setTimeout(() => {
                    window.location.href = 'https://razorpay.com/payment_success?razorpay_payment_id=' + data.paymentId;
                  }, 1500);
                } else {
                  statusDiv.className = 'failure';
                  statusDiv.innerText = 'Payment failed or cancelled. Redirecting...';
                  
                  // Redirect to a failure URL to trigger detection
                  setTimeout(() => {
                    window.location.href = 'https://razorpay.com/payment_failed';
                  }, 1500);
                }
              }
            }

            // Initialize Razorpay
            (function(){
              var d=document; var x=!d.getElementById('razorpay-embed-btn-js')
              if(x){ 
                var s=d.createElement('script'); 
                s.defer=!0;
                s.id='razorpay-embed-btn-js';
                s.src='https://cdn.razorpay.com/static/embed_btn/bundle.js';
                s.onload = function() {
                  // Monitor for Razorpay events after script loads
                  if (window.__rzp__) {
                    const originalInit = window.__rzp__.init;
                    window.__rzp__.init = function() {
                      const result = originalInit.apply(this, arguments);
                      
                      // Get the RazorpayCheckout instance
                      const checkout = window.Razorpay.checkoutInstance;
                      if (checkout) {
                        // Add event listeners for payment events
                        checkout.on('payment.success', function(response) {
                          console.log('Payment Success:', response);
                          notifyFlutter('paymentSuccess', {
                            paymentId: response.razorpay_payment_id,
                            orderId: response.razorpay_order_id
                          });
                        });
                        
                        checkout.on('payment.error', function(response) {
                          console.log('Payment Error:', response);
                          notifyFlutter('paymentFailure', {
                            error: response.error || 'Payment failed'
                          });
                        });
                      }
                      
                      return result;
                    };
                  }
                };
                d.body.appendChild(s);
              } else {
                var rzp=window['__rzp__'];
                rzp && rzp.init && rzp.init();
              }
              
              // Periodically check for payment completion
              setInterval(function() {
                const status = localStorage.getItem('payment_status');
                if (status) {
                  console.log('Found payment status:', status);
                  try {
                    const data = JSON.parse(localStorage.getItem('payment_data') || '{}');
                    if (status === 'paymentSuccess') {
                      window.location.href = 'https://razorpay.com/payment_success?razorpay_payment_id=' + 
                        (data.paymentId || 'unknown');
                    } else {
                      window.location.href = 'https://razorpay.com/payment_failed';
                    }
                  } catch (e) {
                    console.error('Error processing payment data:', e);
                  }
                }
              }, 2000);
            })();
          </script>
        </div>
      </div>
    </body>
    </html>
  ''';

  late final WebViewController _webViewController;
  bool isPaymentFailed = false;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    
    // Start the force close timer when the page is loaded
    // This ensures the user isn't stuck in the WebView if callbacks fail
    _startForceCloseTimer();
  }
  
  @override
  void dispose() {
    _forceCloseTimer?.cancel();
    super.dispose();
  }
  
  void _startForceCloseTimer() {
    // Cancel any existing timer
    _forceCloseTimer?.cancel();
    
    // Start a new timer that will force close the WebView if no callback is received
    _forceCloseTimer = Timer(Duration(seconds: _forceCloseTimerDuration), () {
      print('Force close timer triggered - payment flow taking too long');
      if (!paymentComplete && !isPaymentFailed) {
        print('No payment callback received, forcing close of WebView');
        // Do not automatically mark as failure, instead check for success indicators first
        _checkPaymentStatus();
      }
    });
  }
  
  void _checkPaymentStatus() {
    // Try to execute JavaScript to check payment status before forcing close
    _webViewController.runJavaScriptReturningResult(
      '''
      (function() {
        // Check if payment is completed in any way
        if (document.body.innerText.includes('successful') || 
            document.body.innerText.includes('success') || 
            document.body.innerText.includes('completed') ||
            localStorage.getItem('payment_status') === 'paymentSuccess') {
          return 'success';
        } else if (document.body.innerText.includes('failed') || 
                 document.body.innerText.includes('failure') || 
                 document.body.innerText.includes('cancelled') ||
                 localStorage.getItem('payment_status') === 'paymentFailure') {
          return 'failure';
        } else {
          return 'unknown';
        }
      })();
      '''
    ).then((result) {
      print('Payment status check result: $result');
      String status = result.toString().toLowerCase();
      
      if (status.contains('success')) {
        print('Force close detected success on page');
        // Extract a dummy payment ID since we don't have the actual one
        String paymentId = 'PAY-FORCE-${DateTime.now().millisecondsSinceEpoch}';
        _handlePaymentSuccess('https://razorpay.com/payment_success?razorpay_payment_id=$paymentId');
      } else {
        print('Force close could not detect success, treating as failure');
        _handlePaymentFailure();
      }
    }).catchError((error) {
      print('Error checking payment status: $error');
      _handlePaymentFailure();
    });
  }
  
  // Handle back button presses to prevent getting stuck
  @override
  Future<bool> didPopRoute() async {
    if (paymentComplete) {
      return false; // Let the system handle it
    }
    _handlePaymentFailure();
    return true;
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Configure WebView settings for better performance
      ..setBackgroundColor(Colors.white)
      // Add multiple JavaScript channels for better communication
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('JS Channel message received: ${message.message}');
          _handleJavaScriptMessage(message.message);
        },
      )
      // Add a channel specifically for logging
      ..addJavaScriptChannel(
        'LogChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('WebView log: ${message.message}');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('WebView - Page started loading: $url');
            setState(() {
              isLoading = true;
            });
            
            // Also check here for payment completion URLs
            _checkForPaymentUrls(url);
          },
          onPageFinished: (String url) {
            print('WebView - Page finished loading: $url');
            setState(() {
              isLoading = false;
            });
            
            // Also check here for payment completion URLs
            _checkForPaymentUrls(url);
            
            // Inject JavaScript to monitor Razorpay events
            _injectRazorpayMonitoring();
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            print('WebView - Navigation request: $url');
            
            // Handle any URL navigation, such as success or failure redirects
            if (_isPaymentSuccessUrl(url)) {
              print('WebView - Success URL detected in navigation request');
              _handlePaymentSuccess(url);
              return NavigationDecision.prevent;
            }
            
            // Check for payment failure URLs
            if (_isPaymentFailureUrl(url)) {
              print('WebView - Failure URL detected in navigation request');
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange urlChange) {
            final url = urlChange.url;
            print('WebView - URL changed: $url');
            
            if (url != null) {
              _checkForPaymentUrls(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(razorpayHtml);
  }
  
  void _handleJavaScriptMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final String event = data['event'];
      
      print('Payment event received: $event');
      
      if (event == 'paymentSuccess') {
        final String paymentId = data['paymentId'] ?? 'unknown';
        final String orderId = data['orderId'] ?? 
            'ORDER-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        
        _handlePaymentSuccess('https://razorpay.com/payment_success?razorpay_payment_id=$paymentId&razorpay_order_id=$orderId');
      } else if (event == 'paymentFailure') {
        _handlePaymentFailure();
      }
    } catch (e) {
      print('Error parsing JavaScript message: $e');
    }
  }
  
  void _injectRazorpayMonitoring() {
    // First inject canvas optimization script to fix the willReadFrequently warning
    final canvasOptimizationScript = '''
    (function() {
      // Override the original getContext method to add willReadFrequently attribute
      const originalGetContext = HTMLCanvasElement.prototype.getContext;
      HTMLCanvasElement.prototype.getContext = function(contextType, contextAttributes) {
        contextAttributes = contextAttributes || {};
        
        // Add willReadFrequently flag for 2d canvas contexts
        if (contextType === '2d') {
          contextAttributes.willReadFrequently = true;
        }
        
        return originalGetContext.call(this, contextType, contextAttributes);
      };
      
      console.log('Canvas optimization applied');
      if (window.LogChannel) {
        window.LogChannel.postMessage('Canvas optimization applied successfully');
      }
    })();
    ''';
    
    // Run the canvas optimization script
    _webViewController.runJavaScript(canvasOptimizationScript).then((_) {
      print('Canvas optimization script injected');
    }).catchError((error) {
      print('Error injecting canvas script: $error');
    });
    
    // Then inject the main monitoring script
    final monitoringScript = '''
    (function() {
      // Flag to prevent multiple callbacks
      let paymentProcessed = false;

      // Function to send messages to Flutter
      function sendToFlutter(event, data) {
        try {
          // Don't send failure event if we've already sent a success event
          if (event === 'paymentFailure' && localStorage.getItem('payment_success_sent') === 'true') {
            console.log('Ignoring failure event because success was already sent');
            return;
          }

          // Mark success as sent to prevent later failure events
          if (event === 'paymentSuccess') {
            localStorage.setItem('payment_success_sent', 'true');
          }

          if (paymentProcessed) {
            console.log('Payment event already processed, ignoring:', event);
            return;
          }

          console.log('Sending event to Flutter:', event, data);
          paymentProcessed = true;
          window.PaymentChannel.postMessage(JSON.stringify({event: event, ...data}));
        } catch(e) {
          console.error('Error sending message to Flutter:', e);
        }
      }
      
      // Look for Razorpay checkout element
      const checkInterval = setInterval(function() {
        if (window.Razorpay && window.Razorpay.checkoutInstance) {
          clearInterval(checkInterval);
          
          console.log('Found Razorpay checkout instance, adding event listeners');
          const checkout = window.Razorpay.checkoutInstance;
          
          checkout.on('payment.success', function(response) {
            console.log('Payment Success:', response);
            // Set flags to prevent any future failure callbacks
            localStorage.setItem('payment_status', 'success');
            localStorage.setItem('payment_success_sent', 'true');
            
            sendToFlutter('paymentSuccess', {
              paymentId: response.razorpay_payment_id,
              orderId: response.razorpay_order_id
            });
            
            // Also redirect to trigger URL-based detection
            setTimeout(() => {
              window.location.href = 'https://razorpay.com/payment_success?razorpay_payment_id=' + 
                response.razorpay_payment_id;
            }, 500);
          });
          
          checkout.on('payment.error', function(response) {
            // Check if success was already sent
            if (localStorage.getItem('payment_success_sent') === 'true') {
              console.log('Success already sent, ignoring error event');
              return;
            }
            
            console.log('Payment Error:', response);
            localStorage.setItem('payment_status', 'failure');
            
            sendToFlutter('paymentFailure', {error: response.error || 'Payment failed'});
            
            // Also redirect to trigger URL-based detection
            setTimeout(() => {
              window.location.href = 'https://razorpay.com/payment_failed';
            }, 500);
          });
        }
      }, 1000);
      
      // Check document for success indicators every 500ms
      const successCheckInterval = setInterval(function() {
        // If already processed, stop checking
        if (paymentProcessed || localStorage.getItem('payment_success_sent') === 'true') {
          clearInterval(successCheckInterval);
          return;
        }

        // Check page content for success indicators
        const bodyText = document.body.innerText.toLowerCase();
        if (bodyText.includes('successful payment') || 
            bodyText.includes('payment successful') ||
            bodyText.includes('transaction successful')) {
            
          console.log('Found success text in page');
          localStorage.setItem('payment_success_sent', 'true');
          
          // Extract payment ID if possible
          let paymentId = 'PAYMENT_FROM_TEXT';
          const paymentElements = document.querySelectorAll('[data-payment-id]');
          if (paymentElements.length > 0) {
            paymentId = paymentElements[0].getAttribute('data-payment-id');
          }
          
          sendToFlutter('paymentSuccess', {
            paymentId: paymentId,
            orderId: 'ORDER_FROM_TEXT'
          });
          
          clearInterval(successCheckInterval);
        }
      }, 500);
      
      // Also check localStorage for payment status
      const storageCheckInterval = setInterval(function() {
        // If already processed, stop checking
        if (paymentProcessed) {
          clearInterval(storageCheckInterval);
          return;
        }
        
        const status = localStorage.getItem('payment_status');
        if (status) {
          console.log('Found payment status in localStorage:', status);
          try {
            const data = JSON.parse(localStorage.getItem('payment_data') || '{}');
            if (status === 'paymentSuccess' || status === 'success') {
              sendToFlutter('paymentSuccess', data);
            } else if (status === 'paymentFailure' || status === 'failure') {
              // Only send failure if success wasn't already sent
              if (localStorage.getItem('payment_success_sent') !== 'true') {
                sendToFlutter('paymentFailure', data);
              }
            }
            clearInterval(storageCheckInterval);
          } catch (e) {
            console.error('Error processing payment data:', e);
          }
        }
      }, 1000);
    })();
    ''';
    
    _webViewController.runJavaScript(monitoringScript);
  }
  
  void _checkForPaymentUrls(String url) {
    if (_isPaymentSuccessUrl(url)) {
      print('WebView - Payment success URL detected: $url');
      _handlePaymentSuccess(url);
    } else if (_isPaymentFailureUrl(url)) {
      print('WebView - Payment failure URL detected: $url');
      _handlePaymentFailure();
    }
  }
  
  bool _isPaymentSuccessUrl(String url) {
    return url.contains('razorpay_payment_id') || 
           url.contains('payment_success') || 
           url.contains('payment_id=') || 
           url.contains('success=true');
  }
  
  bool _isPaymentFailureUrl(String url) {
    return url.contains('payment_failed') || 
           url.contains('payment_cancel') || 
           url.contains('cancel=true') || 
           url.contains('failure=true') ||
           url.contains('error=true') ||
           url.contains('cancel');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _handlePaymentFailure(),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _handlePaymentSuccess(String url) {
    if (paymentComplete) {
      print("Payment already completed, ignoring duplicate success event");
      return; // Prevent multiple triggers
    }
    
    // Cancel any pending force close timer
    _forceCloseTimer?.cancel();
    
    paymentComplete = true;
    isPaymentFailed = false; // Ensure we don't trigger failure after success
    print("Payment success detected: $url");
    
    // Extract payment ID and order ID from URL
    String? paymentId;
    try {
      final uri = Uri.parse(url);
      paymentId = uri.queryParameters['razorpay_payment_id'];
      if (paymentId == null) {
        // Try to find payment ID in other formats
        paymentId = uri.queryParameters['payment_id'];
      }
      
      orderId = uri.queryParameters['razorpay_order_id'] ?? 
          uri.queryParameters['order_id'] ?? 
          'ORDER-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      print("Extracted paymentId: $paymentId, orderId: $orderId");
    } catch (e) {
      print("Error parsing URL: $e");
      // Generate a payment ID if we couldn't parse one
      paymentId = 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      orderId ??= 'ORDER-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
    
    // Add a delay to ensure the WebView state is stable before navigation
    Future.delayed(const Duration(milliseconds: 500), () {
      // Close the WebView and go back to the previous screen
      if (widget.onPaymentSuccess != null) {
        print("Calling success callback with paymentId: $paymentId, orderId: $orderId");
        
        // Close current screen first
        Navigator.of(context).pop();
        
        // Then call the success callback
        widget.onPaymentSuccess!(paymentId, orderId);
      } else {
        print("No success callback provided, using default behavior");
        
        // Default success behavior
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(
              orderId: orderId!,
              totalAmount: widget.totalAmount,
            ),
          ),
        );
      }
    });
  }
  
  void _handlePaymentFailure() {
    // If payment was already marked as successful, don't override with a failure
    if (paymentComplete) {
      print("Payment already completed successfully, ignoring failure event");
      return;
    }
    
    // If we already marked it as failed, don't trigger again
    if (isPaymentFailed) {
      print("Payment already failed, ignoring duplicate failure event");
      return;
    }
    
    // Cancel any pending force close timer
    _forceCloseTimer?.cancel();
    
    isPaymentFailed = true;
    print("Payment failure or cancellation detected");
    
    // Add a delay to ensure the WebView state is stable before navigation
    Future.delayed(const Duration(milliseconds: 500), () {
      // Close the WebView and go back to the previous screen
      if (widget.onPaymentFailure != null) {
        print("Calling payment failure callback");
        // Close current screen first
        Navigator.of(context).pop();
        // Then call the failure callback
        widget.onPaymentFailure!();
      } else {
        print("No failure callback provided, using default behavior");
        // Default failure behavior - just go back
        Navigator.of(context).pop();
        // Show a failure message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was cancelled or failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
