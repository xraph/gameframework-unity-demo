import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:green/green.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Unity engine plugin
  UnityEnginePlugin.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  GameEngineController? _controller;
  double _targetSpeed = 50.0; // The slider value (target speed)
  String _rotationAxis = 'Y';
  bool _isReady = false;
  String _lastMessage = 'Initializing...';
  String _direction = '---';
  double _currentSpeed = 0;
  double _currentRpm = 0;
  
  // UI State
  bool _isPanelExpanded = false;
  final bool _showMiniHud = true;
  late AnimationController _panelAnimationController;
  late Animation<double> _panelAnimation;

  @override
  void initState() {
    super.initState();
    _panelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _panelAnimation = CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _panelAnimationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isPanelExpanded = !_isPanelExpanded;
      if (_isPanelExpanded) {
        _panelAnimationController.forward();
      } else {
        _panelAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.blueAccent,
          thumbColor: Colors.blue,
          overlayColor: Colors.blue.withOpacity(0.2),
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Unity game view (full screen)
            GreenWidget(
              onEngineCreated: (controller) {
                setState(() {
                  _controller = controller;
                });
              },
              onMessage: (message) {
                print('📨 Received from Unity: ${message.method} - ${message.data}');
                
                final method = message.method;
                if (method == null) return;
                
                if (method == 'onReady') {
                  setState(() {
                    _isReady = true;
                    _lastMessage = 'Unity ready!';
                    _direction = '← UNITY';
                  });
                } else if (method == 'onSpeedChanged' || method == 'onCurrentSpeed') {
                  try {
                    final data = message.asJson();
                    if (data != null) {
                      setState(() {
                        _currentSpeed = (data['speed'] as num?)?.toDouble() ?? 0;
                        _currentRpm = (data['rpm'] as num?)?.toDouble() ?? 0;
                        // Check if this is a touch-initiated speed change
                        final isTouch = data['isTouch'] as bool? ?? false;
                        if (isTouch) {
                          _lastMessage = 'Touch spin!';
                        }
                        _direction = '← UNITY';
                      });
                    }
                  } catch (e) {
                    print('Error parsing speed data: $e');
                  }
                } else if (method == 'onState') {
                  setState(() {
                    _lastMessage = 'State received';
                    _direction = '← UNITY';
                  });
                } else if (method == 'onReset') {
                  setState(() {
                    _targetSpeed = 50;
                    _rotationAxis = 'Y';
                    _lastMessage = 'Reset';
                    _direction = '← UNITY';
                  });
                }
              },
              onSceneLoaded: (sceneInfo) {
                print('Scene loaded: ${sceneInfo.name}');
              },
            ),
            
            // Mini HUD (top-left, always visible when panel is collapsed)
            if (_showMiniHud && !_isPanelExpanded && _isReady)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: _buildMiniHud(),
              ),
            
            // Expandable Control Panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildExpandablePanel(),
            ),
            
            // Floating Action Buttons (right side)
            Positioned(
              right: 16,
              bottom: _isPanelExpanded ? 320 : 100,
              child: _buildFloatingActions(),
            ),
            
            // Loading overlay
            if (!_isReady)
              Container(
                // color: Colors.black87,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading Unity...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniHud() {
    return GestureDetector(
      onTap: _togglePanel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.speed,
              color: Colors.amber,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '${_currentSpeed.abs().toStringAsFixed(0)}°/s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _direction.contains('UNITY') ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.touch_app,
              color: Colors.blue.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle panel button
        FloatingActionButton(
          heroTag: 'toggle',
          mini: true,
          backgroundColor: Colors.blueGrey.withOpacity(0.9),
          onPressed: _togglePanel,
          child: AnimatedRotation(
            turns: _isPanelExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.expand_less, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        // Quick actions when panel is collapsed
        if (!_isPanelExpanded) ...[
          FloatingActionButton(
            heroTag: 'color',
            mini: true,
            backgroundColor: Colors.purple.withOpacity(0.9),
            onPressed: _isReady ? _randomColor : null,
            child: const Icon(Icons.palette, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'reset',
            mini: true,
            backgroundColor: Colors.orange.withOpacity(0.9),
            onPressed: _isReady ? _reset : null,
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandablePanel() {
    return AnimatedBuilder(
      animation: _panelAnimation,
      builder: (context, child) {
        return Container(
          height: 80 + (_panelAnimation.value * 220),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              GestureDetector(
                onTap: _togglePanel,
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    if (!_isPanelExpanded) _togglePanel();
                  } else if (details.primaryVelocity! > 0) {
                    if (_isPanelExpanded) _togglePanel();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Compact speed control (always visible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.speed, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: _targetSpeed,
                          min: -180,
                          max: 180,
                          onChanged: _isReady ? (value) {
                            setState(() => _targetSpeed = value);
                            _sendSpeed(value);
                          } : null,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_targetSpeed.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Expanded content
              if (_panelAnimation.value > 0.1)
                Expanded(
                  child: Opacity(
                    opacity: _panelAnimation.value,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        children: [
                          // Axis selector
                          _buildCompactAxisSelector(),
                          const SizedBox(height: 16),
                          
                          // Info row
                          _buildInfoRow(),
                          const SizedBox(height: 16),
                          
                          // Action buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactAxisSelector() {
    return Row(
      children: [
        const Icon(Icons.loop, color: Colors.greenAccent, size: 18),
        const SizedBox(width: 8),
        const Text(
          'Axis',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const Spacer(),
        ...['X', 'Y', 'Z', 'All'].map((axis) => Padding(
          padding: const EdgeInsets.only(left: 6),
          child: _buildCompactAxisButton(axis),
        )),
      ],
    );
  }

  Widget _buildCompactAxisButton(String axis) {
    final isSelected = _rotationAxis == axis;
    final color = axis == 'X' ? Colors.red 
                 : axis == 'Y' ? Colors.green 
                 : axis == 'Z' ? Colors.blue 
                 : Colors.purple;
    
    return GestureDetector(
      onTap: _isReady ? () {
        setState(() => _rotationAxis = axis);
        _setAxis(axis);
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          axis,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildInfoItem(
            Icons.speed,
            'Current',
            '${_currentSpeed.abs().toStringAsFixed(0)}°/s',
            Colors.amber,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          _buildInfoItem(
            Icons.rotate_right,
            'RPM',
            _currentRpm.abs().toStringAsFixed(1),
            Colors.cyan,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: _buildInfoItem(
              _direction.contains('UNITY') ? Icons.arrow_back : Icons.arrow_forward,
              'Status',
              _lastMessage,
              _direction.contains('UNITY') ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildCompactButton('Reset', Icons.refresh, Colors.orange, _reset)),
        const SizedBox(width: 8),
        Expanded(child: _buildCompactButton('State', Icons.analytics, Colors.blue, _getState)),
        const SizedBox(width: 8),
        Expanded(child: _buildCompactButton('Color', Icons.palette, Colors.purple, _randomColor)),
      ],
    );
  }

  Widget _buildCompactButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isReady ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _sendSpeed(double speed) {
    _controller?.sendMessage('GameFrameworkDemo', 'setSpeed', speed.toString());
    setState(() {
      _lastMessage = 'Speed: ${speed.toStringAsFixed(0)}°';
      _direction = '→ UNITY';
    });
  }

  void _setAxis(String axis) {
    Map<String, dynamic> axisData;
    switch (axis) {
      case 'X':
        axisData = {'x': 1.0, 'y': 0.0, 'z': 0.0};
        break;
      case 'Y':
        axisData = {'x': 0.0, 'y': 1.0, 'z': 0.0};
        break;
      case 'Z':
        axisData = {'x': 0.0, 'y': 0.0, 'z': 1.0};
        break;
      case 'All':
        axisData = {'x': 1.0, 'y': 1.0, 'z': 1.0};
        break;
      default:
        axisData = {'x': 0.0, 'y': 1.0, 'z': 0.0};
    }
    
    _controller?.sendJsonMessage('GameFrameworkDemo', 'setAxis', axisData);
    setState(() {
      _lastMessage = 'Axis: $axis';
      _direction = '→ UNITY';
    });
  }

  void _reset() {
    _controller?.sendMessage('GameFrameworkDemo', 'reset', '');
    setState(() {
      _targetSpeed = 50;
      _rotationAxis = 'Y';
      _lastMessage = 'Reset';
      _direction = '→ UNITY';
    });
  }

  void _getState() {
    _controller?.sendMessage('GameFrameworkDemo', 'getState', '');
    setState(() {
      _lastMessage = 'Get state';
      _direction = '→ UNITY';
    });
  }

  void _randomColor() {
    final random = math.Random();
    final colorData = {
      'r': random.nextDouble() * 0.5 + 0.3,
      'g': random.nextDouble() * 0.5 + 0.3,
      'b': random.nextDouble() * 0.5 + 0.3,
      'a': 1.0,
    };
    
    _controller?.sendJsonMessage('GameFrameworkDemo', 'setColor', colorData);
    setState(() {
      _lastMessage = 'New color';
      _direction = '→ UNITY';
    });
  }
}
