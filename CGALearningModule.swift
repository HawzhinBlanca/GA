import SwiftUI
import SceneKit
import simd

/// A comprehensive learning module for Conformal Geometric Algebra
public struct CGALearningModule: View {
    // MARK: - State Properties
    
    /// The lesson currently being displayed
    @State private var currentLesson: CGALesson = .introduction
    
    /// The visualizer for 3D content
    @State private var visualizer = GAVisualizer()
    
    /// Whether to show step-by-step explanations
    @State private var showStepByStep = true
    
    /// Whether to show interactive elements
    @State private var showInteractive = true
    
    /// Visualization IDs for entities
    @State private var entityIDs: [String: UUID] = [:]
    
    /// Parameters for the current lesson
    @State private var lessonParameters = LessonParameters()
    
    /// Current step in the step-by-step explanation
    @State private var currentStep = 0
    
    // MARK: - Body
    
    public var body: some View {
        HSplitView {
            // Left sidebar: Lesson selection
            VStack(alignment: .leading) {
                Text("Conformal GA")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                List(CGALesson.allCases, id: \.self, selection: $currentLesson) { lesson in
                    Text(lesson.title)
                }
                .listStyle(SidebarListStyle())
                .frame(minWidth: 200)
                
                Spacer()
                
                // Options panel
                VStack(alignment: .leading, spacing: 10) {
                    Text("Display Options")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Toggle("Step-by-Step", isOn: $showStepByStep)
                        .padding(.horizontal)
                        .onChange(of: showStepByStep) { _ in
                            updateVisualization()
                        }
                    
                    Toggle("Interactive Mode", isOn: $showInteractive)
                        .padding(.horizontal)
                        .onChange(of: showInteractive) { _ in
                            updateVisualization()
                        }
                }
                .padding(.vertical)
            }
            
            // Right side: Lesson content
            VStack {
                // Top: 3D visualization
                GASceneViewAdapter(visualizer: visualizer)
                    .frame(height: 300)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                
                // Bottom: Lesson content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Lesson title
                        Text(currentLesson.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Lesson content
                        lessonContent
                        
                        // Interactive controls (if enabled)
                        if showInteractive {
                            interactiveControls
                        }
                        
                        // Step-by-Step explanation (if enabled)
                        if showStepByStep {
                            stepByStepExplanation
                        }
                    }
                    .padding()
                    .animation(.easeInOut, value: currentLesson)
                }
            }
        }
        .onAppear {
            // Initial setup
            setupVisualization()
        }
        .onChange(of: currentLesson) { _ in
            // Update visualization when lesson changes
            resetLessonParameters()
            updateVisualization()
        }
    }
    
    // MARK: - Lesson Content
    
    /// The content for the current lesson
    @ViewBuilder
    private var lessonContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Lesson description
            Text(currentLesson.description)
                .font(.body)
                .padding(.bottom, 8)
            
            // Mathematical background
            if let mathBackground = currentLesson.mathematicalBackground {
                Section {
                    Text("Mathematical Background")
                        .font(.headline)
                    
                    Text(mathBackground)
                        .font(.body)
                }
                .padding(.vertical, 8)
            }
            
            // Core formula
            if let formula = currentLesson.coreFormula {
                Section {
                    Text("Key Formula")
                        .font(.headline)
                    
                    EquationView(formula, size: .large)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.vertical, 8)
            }
            
            // Applications
            if let applications = currentLesson.applications {
                Section {
                    Text("Applications")
                        .font(.headline)
                    
                    Text(applications)
                        .font(.body)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - Interactive Controls
    
    /// Interactive controls for the current lesson
    @ViewBuilder
    private var interactiveControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive Controls")
                .font(.headline)
            
            switch currentLesson {
            case .introduction:
                // No controls for introduction
                Text("Explore the visualization above to understand the basic CGA model.")
                
            case .points:
                // Controls for points lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Point in 3D space")
                        .font(.subheadline)
                    
                    VStack {
                        HStack {
                            Text("X:")
                            Slider(value: $lessonParameters.point.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.point.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Y:")
                            Slider(value: $lessonParameters.point.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.point.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Z:")
                            Slider(value: $lessonParameters.point.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.point.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: lessonParameters.point) { _ in
                        updateVisualization()
                    }
                }
                
            case .spheres:
                // Controls for spheres lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sphere Parameters")
                        .font(.subheadline)
                    
                    VStack {
                        HStack {
                            Text("Center X:")
                            Slider(value: $lessonParameters.sphereCenter.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphereCenter.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Y:")
                            Slider(value: $lessonParameters.sphereCenter.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphereCenter.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Z:")
                            Slider(value: $lessonParameters.sphereCenter.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphereCenter.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Radius:")
                            Slider(value: $lessonParameters.sphereRadius, in: 0.1...5)
                            Text(String(format: "%.1f", lessonParameters.sphereRadius))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: lessonParameters.sphereCenter) { _ in
                        updateVisualization()
                    }
                    .onChange(of: lessonParameters.sphereRadius) { _ in
                        updateVisualization()
                    }
                }
                
            case .planes:
                // Controls for planes lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plane Parameters")
                        .font(.subheadline)
                    
                    VStack {
                        HStack {
                            Text("Normal X:")
                            Slider(value: $lessonParameters.planeNormal.x, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Y:")
                            Slider(value: $lessonParameters.planeNormal.y, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Z:")
                            Slider(value: $lessonParameters.planeNormal.z, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Distance:")
                            Slider(value: $lessonParameters.planeDistance, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.planeDistance))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: lessonParameters.planeNormal) { _ in
                        // Normalize the normal vector
                        let length = simd_length(lessonParameters.planeNormal)
                        if length > 0 {
                            lessonParameters.planeNormal = lessonParameters.planeNormal / length
                        }
                        updateVisualization()
                    }
                    .onChange(of: lessonParameters.planeDistance) { _ in
                        updateVisualization()
                    }
                }
                
            case .circles:
                // Controls for circles lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Circle Parameters")
                        .font(.subheadline)
                    
                    VStack {
                        HStack {
                            Text("Center X:")
                            Slider(value: $lessonParameters.circleCenter.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.circleCenter.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Y:")
                            Slider(value: $lessonParameters.circleCenter.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.circleCenter.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Z:")
                            Slider(value: $lessonParameters.circleCenter.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.circleCenter.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Radius:")
                            Slider(value: $lessonParameters.circleRadius, in: 0.1...5)
                            Text(String(format: "%.1f", lessonParameters.circleRadius))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        Divider()
                        
                        Text("Circle Plane Normal")
                            .font(.subheadline)
                        
                        HStack {
                            Text("Normal X:")
                            Slider(value: $lessonParameters.circleNormal.x, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.circleNormal.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Y:")
                            Slider(value: $lessonParameters.circleNormal.y, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.circleNormal.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Z:")
                            Slider(value: $lessonParameters.circleNormal.z, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.circleNormal.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: lessonParameters.circleCenter) { _ in
                        updateVisualization()
                    }
                    .onChange(of: lessonParameters.circleRadius) { _ in
                        updateVisualization()
                    }
                    .onChange(of: lessonParameters.circleNormal) { _ in
                        // Normalize the normal vector
                        let length = simd_length(lessonParameters.circleNormal)
                        if length > 0 {
                            lessonParameters.circleNormal = lessonParameters.circleNormal / length
                        }
                        updateVisualization()
                    }
                }
                
            case .lines:
                // Controls for lines lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Line Parameters")
                        .font(.subheadline)
                    
                    VStack {
                        HStack {
                            Text("Point 1 X:")
                            Slider(value: $lessonParameters.linePoint1.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint1.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 1 Y:")
                            Slider(value: $lessonParameters.linePoint1.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint1.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 1 Z:")
                            Slider(value: $lessonParameters.linePoint1.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint1.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Point 2 X:")
                            Slider(value: $lessonParameters.linePoint2.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint2.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 2 Y:")
                            Slider(value: $lessonParameters.linePoint2.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint2.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 2 Z:")
                            Slider(value: $lessonParameters.linePoint2.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint2.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: lessonParameters.linePoint1) { _ in
                        updateVisualization()
                    }
                    .onChange(of: lessonParameters.linePoint2) { _ in
                        updateVisualization()
                    }
                }
                
            case .pointPairs:
                // Controls for point pairs lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Point Pair Parameters")
                        .font(.subheadline)
                    
                    VStack {
                        HStack {
                            Text("Point 1 X:")
                            Slider(value: $lessonParameters.pairPoint1.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.pairPoint1.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 1 Y:")
                            Slider(value: $lessonParameters.pairPoint1.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.pairPoint1.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 1 Z:")
                            Slider(value: $lessonParameters.pairPoint1.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.pairPoint1.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Point 2 X:")
                            Slider(value: $lessonParameters.pairPoint2.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.pairPoint2.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 2 Y:")
                            Slider(value: $lessonParameters.pairPoint2.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.pairPoint2.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 2 Z:")
                            Slider(value: $lessonParameters.pairPoint2.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.pairPoint2.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: lessonParameters.pairPoint1) { _ in
                        updateVisualization()
                    }
                    .onChange(of: lessonParameters.pairPoint2) { _ in
                        updateVisualization()
                    }
                }
                
            case .intersections:
                // Controls for intersections lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intersection Types")
                        .font(.subheadline)
                    
                    Picker("Intersection Type", selection: $lessonParameters.intersectionType) {
                        Text("Sphere-Plane").tag(IntersectionType.spherePlane)
                        Text("Sphere-Sphere").tag(IntersectionType.sphereSphere)
                        Text("Plane-Line").tag(IntersectionType.planeLine)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 8)
                    
                    switch lessonParameters.intersectionType {
                    case .spherePlane:
                        Text("Sphere Parameters")
                            .font(.subheadline)
                        
                        HStack {
                            Text("Center X:")
                            Slider(value: $lessonParameters.sphereCenter.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphereCenter.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Y:")
                            Slider(value: $lessonParameters.sphereCenter.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphereCenter.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Z:")
                            Slider(value: $lessonParameters.sphereCenter.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphereCenter.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Radius:")
                            Slider(value: $lessonParameters.sphereRadius, in: 0.1...5)
                            Text(String(format: "%.1f", lessonParameters.sphereRadius))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        Divider()
                        
                        Text("Plane Parameters")
                            .font(.subheadline)
                        
                        HStack {
                            Text("Normal X:")
                            Slider(value: $lessonParameters.planeNormal.x, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Y:")
                            Slider(value: $lessonParameters.planeNormal.y, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Z:")
                            Slider(value: $lessonParameters.planeNormal.z, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Distance:")
                            Slider(value: $lessonParameters.planeDistance, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.planeDistance))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                    case .sphereSphere:
                        Text("Sphere 1 Parameters")
                            .font(.subheadline)
                        
                        HStack {
                            Text("Center X:")
                            Slider(value: $lessonParameters.sphere1Center.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphere1Center.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Y:")
                            Slider(value: $lessonParameters.sphere1Center.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphere1Center.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Z:")
                            Slider(value: $lessonParameters.sphere1Center.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphere1Center.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Radius:")
                            Slider(value: $lessonParameters.sphere1Radius, in: 0.1...5)
                            Text(String(format: "%.1f", lessonParameters.sphere1Radius))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        Divider()
                        
                        Text("Sphere 2 Parameters")
                            .font(.subheadline)
                        
                        HStack {
                            Text("Center X:")
                            Slider(value: $lessonParameters.sphere2Center.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphere2Center.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Y:")
                            Slider(value: $lessonParameters.sphere2Center.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphere2Center.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Center Z:")
                            Slider(value: $lessonParameters.sphere2Center.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.sphere2Center.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Radius:")
                            Slider(value: $lessonParameters.sphere2Radius, in: 0.1...5)
                            Text(String(format: "%.1f", lessonParameters.sphere2Radius))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                    case .planeLine:
                        Text("Plane Parameters")
                            .font(.subheadline)
                        
                        HStack {
                            Text("Normal X:")
                            Slider(value: $lessonParameters.planeNormal.x, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Y:")
                            Slider(value: $lessonParameters.planeNormal.y, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Normal Z:")
                            Slider(value: $lessonParameters.planeNormal.z, in: -1...1)
                            Text(String(format: "%.1f", lessonParameters.planeNormal.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Distance:")
                            Slider(value: $lessonParameters.planeDistance, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.planeDistance))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        Divider()
                        
                        Text("Line Parameters")
                            .font(.subheadline)
                        
                        HStack {
                            Text("Point 1 X:")
                            Slider(value: $lessonParameters.linePoint1.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint1.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 1 Y:")
                            Slider(value: $lessonParameters.linePoint1.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint1.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 1 Z:")
                            Slider(value: $lessonParameters.linePoint1.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint1.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 2 X:")
                            Slider(value: $lessonParameters.linePoint2.x, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint2.x))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 2 Y:")
                            Slider(value: $lessonParameters.linePoint2.y, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint2.y))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                        
                        HStack {
                            Text("Point 2 Z:")
                            Slider(value: $lessonParameters.linePoint2.z, in: -5...5)
                            Text(String(format: "%.1f", lessonParameters.linePoint2.z))
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: lessonParameters.sphereCenter) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.sphereRadius) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.planeNormal) { _ in
                        // Normalize
                        let length = simd_length(lessonParameters.planeNormal)
                        if length > 0 {
                            lessonParameters.planeNormal = lessonParameters.planeNormal / length
                        }
                        updateVisualization()
                    }
                    .onChange(of: lessonParameters.planeDistance) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.sphere1Center) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.sphere1Radius) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.sphere2Center) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.sphere2Radius) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.linePoint1) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.linePoint2) { _ in updateVisualization() }
                    .onChange(of: lessonParameters.intersectionType) { _ in updateVisualization() }
                }
                
            case .transformations:
                // Controls for transformations lesson
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transformation Type")
                        .font(.subheadline)
                    
                    Picker("Transformation", selection: $lessonParameters.transformationType) {
                        Text("Translation").tag(TransformationType.translation)
                        Text("Rotation").tag(TransformationType.rotation)
                        Text("Dilation").tag(TransformationType.dilation)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 8)
                    
                    VStack {
                        Text("Object to Transform")
                            .font(.subheadline)
                        
                        Picker("Object", selection: $lessonParameters.transformObject) {
                            Text("Sphere").tag(TransformObject.sphere)
                            Text("Line").tag(TransformObject.line)
                            Text("Point Pair").tag(TransformObject.pointPair)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom, 8)
                        
                        // Object parameters based on selection
                        switch lessonParameters.transformObject {
                        case .sphere:
                            HStack {
                                Text("Sphere Center X:")
                                Slider(value: $lessonParameters.sphereCenter.x, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.sphereCenter.x))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Sphere Center Y:")
                                Slider(value: $lessonParameters.sphereCenter.y, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.sphereCenter.y))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Sphere Center Z:")
                                Slider(value: $lessonParameters.sphereCenter.z, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.sphereCenter.z))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Sphere Radius:")
                                Slider(value: $lessonParameters.sphereRadius, in: 0.1...5)
                                Text(String(format: "%.1f", lessonParameters.sphereRadius))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                        case .line:
                            HStack {
                                Text("Line Point 1 X:")
                                Slider(value: $lessonParameters.linePoint1.x, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.linePoint1.x))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Line Point 1 Y:")
                                Slider(value: $lessonParameters.linePoint1.y, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.linePoint1.y))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Line Point 1 Z:")
                                Slider(value: $lessonParameters.linePoint1.z, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.linePoint1.z))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Line Point 2 X:")
                                Slider(value: $lessonParameters.linePoint2.x, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.linePoint2.x))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Line Point 2 Y:")
                                Slider(value: $lessonParameters.linePoint2.y, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.linePoint2.y))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Line Point 2 Z:")
                                Slider(value: $lessonParameters.linePoint2.z, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.linePoint2.z))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                        case .pointPair:
                            HStack {
                                Text("Point 1 X:")
                                Slider(value: $lessonParameters.pairPoint1.x, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.pairPoint1.x))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Point 1 Y:")
                                Slider(value: $lessonParameters.pairPoint1.y, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.pairPoint1.y))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Point 1 Z:")
                                Slider(value: $lessonParameters.pairPoint1.z, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.pairPoint1.z))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Point 2 X:")
                                Slider(value: $lessonParameters.pairPoint2.x, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.pairPoint2.x))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Point 2 Y:")
                                Slider(value: $lessonParameters.pairPoint2.y, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.pairPoint2.y))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Point 2 Z:")
                                Slider(value: $lessonParameters.pairPoint2.z, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.pairPoint2.z))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                        }
                        
                        Divider()
                        
                        // Transformation parameters based on type
                        Text("Transformation Parameters")
                            .font(.subheadline)
                        
                        switch lessonParameters.transformationType {
                        case .translation:
                            HStack {
                                Text("Translation X:")
                                Slider(value: $lessonParameters.translation.x, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.translation.x))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Translation Y:")
                                Slider(value: $lessonParameters.translation.y, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.translation.y))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Translation Z:")
                                Slider(value: $lessonParameters.translation.z, in: -5...5)
                                Text(String(format: "%.1f", lessonParameters.translation.z))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                        case .rotation:
                            HStack {
                                Text("Rotation Axis X:")
                                Slider(value: $lessonParameters.rotationAxis.x, in: -1...1)
                                Text(String(format: "%.1f", lessonParameters.rotationAxis.x))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Rotation Axis Y:")
                                Slider(value: $lessonParameters.rotationAxis.y, in: -1...1)
                                Text(String(format: "%.1f", lessonParameters.rotationAxis.y))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Rotation Axis Z:")
                                Slider(value: $lessonParameters.rotationAxis.z, in: -1...1)
                                Text(String(format: "%.1f", lessonParameters.rotationAxis.z))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Rotation Angle:")
                                Slider(value: $lessonParameters.rotationAngle, in: 0...Double.pi*2)
                                Text(String(format: "%.1f°", lessonParameters.rotationAngle * 180 / Double.pi))
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                            }
                        }
                            
                            /// Get the mathematical background for the lesson
                            public var mathematicalBackground: String? {
                                switch self {
                                case .introduction:
                                    return "The conformal model extends the Euclidean space ℝⁿ by adding two null basis vectors e₀ and e∞, resulting in an (n+2)-dimensional space with signature (n+1,1). This creates a model where standard Euclidean transformations become linear transformations."
                                    
                                case .points:
                                    return "Let a point p in 3D space be represented in CGA by the multivector P = e₀ + p + ½p²e∞. This maps a point p ∈ ℝ³ to a null vector P in the conformal space with P² = 0. The inner product between two conformal points is related to the Euclidean distance between their corresponding 3D points."
                                    
                                case .spheres:
                                    return "A sphere in CGA can be represented directly as s = c - ½r²e∞, where c is the center and r is the radius. A point p lies on the sphere if and only if the inner product P·s = 0, where P is the conformal representation of p."
                                    
                                case .planes:
                                    return "A plane in CGA is represented by the dual form π = n + de∞, where n is the normal vector and d is the distance from the origin. This form arises from the outer product of three points on the plane and the point at infinity."
                                    
                                case .circles:
                                    return "A circle in CGA can be represented as the intersection of a sphere and a plane, or directly as the wedge product of three points. It has the form z = c - ½r²e∞ ∧ (n + de∞), where c is the center of the circle, r is its radius, and n is the normal to its plane."
                                    
                                case .lines:
                                    return "A line in CGA is represented by the wedge product L = P₁ ∧ P₂ ∧ e∞, where P₁ and P₂ are the conformal representations of two points on the line. Alternatively, a line can be seen as the meet of two planes."
                                    
                                case .pointPairs:
                                    return "A point pair in CGA is represented by the wedge product of two conformal points: Pp = P₁ ∧ P₂. It can also be seen as a degenerate circle or the intersection of a line and a sphere."
                                    
                                case .intersections:
                                    return "The meet operation in CGA allows for computing intersections between geometric entities: X ∨ Y = (X̃ ∧ Ỹ)~, where X̃ denotes the dual of X. This operation provides a coordinate-free way to compute intersections."
                                    
                                case .transformations:
                                    return "Transformations in CGA are represented by versors (products of vectors). A general transformation is applied to an entity X using the sandwich product: X' = VXV⁻¹, where V is the versor representing the transformation."
                                    
                                case .applications:
                                    return "Applications of CGA span computer graphics, robotics, computer vision, and more. The unified treatment of transformations and coordinate-free approach to geometric entities make it powerful for these fields."
                                }
                            }
                            
                            /// Get the core formula for the lesson
                            public var coreFormula: String? {
                                switch self {
                                case .introduction:
                                    return "\\text{The key elements of CGA are the basis vectors } e_0 \\text{ and } e_{\\infty} \\text{ with properties:}\\\\ e_0^2 = 0, \\quad e_{\\infty}^2 = 0, \\quad e_0 \\cdot e_{\\infty} = -1"
                                    
                                case .points:
                                    return "P = e_0 + \\vec{p} + \\frac{1}{2}\\vec{p}^2e_{\\infty} \\quad \\text{where} \\quad \\vec{p} = (x, y, z)"
                                    
                                case .spheres:
                                    return "s^* = c - \\frac{1}{2}r^2e_{\\infty} \\quad \\text{(dual form)}"
                                    
                                case .planes:
                                    return "\\pi^* = \\vec{n} + de_{\\infty} \\quad \\text{where } \\vec{n} \\text{ is the normal and } d \\text{ is the distance}"
                                    
                                case .circles:
                                    return "z = s^* \\wedge \\pi^* = \\text{sphere} \\wedge \\text{plane}"
                                    
                                case .lines:
                                    return "L = P_1 \\wedge P_2 \\wedge e_{\\infty}"
                                    
                                case .pointPairs:
                                    return "Pp = P_1 \\wedge P_2"
                                    
                                case .intersections:
                                    return "A \\vee B = \\left(\\tilde{A} \\wedge \\tilde{B}\\right)^{\\sim} \\quad \\text{(meet operation)}"
                                    
                                case .transformations:
                                    return "X' = V X V^{-1} \\quad \\text{where } V \\text{ is a versor}"
                                    
                                case .applications:
                                    return "\\text{Conformal Geometric Algebra } \\rightarrow \\begin{cases} \\text{Computer Graphics} \\\\ \\text{Robotics} \\\\ \\text{Computer Vision} \\\\ \\text{Physics} \\end{cases}"
                                }
                            }
                            
                            /// Get the applications for the lesson
                            public var applications: String? {
                                switch self {
                                case .introduction:
                                    return "CGA is used in computer graphics for representing 3D scenes, in robotics for motion planning, and in computer vision for feature detection and tracking."
                                    
                                case .points:
                                    return "The CGA representation of points is useful in computer vision for feature point matching, in robotics for path planning, and in physics for modeling particle interactions."
                                    
                                case .spheres:
                                    return "Spheres in CGA are used in computer graphics for collision detection, in medical imaging for modeling anatomical structures, and in physics for representing fields and potentials."
                                    
                                case .planes:
                                    return "Planes in CGA are used in computer vision for segmentation, in robotics for surface alignment, and in computer graphics for shadow calculations and reflections."
                                    
                                case .circles:
                                    return "Circles in CGA are used in computer vision for detecting circular features, in robotics for cylindrical object manipulation, and in engineering for modeling circular motion."
                                    
                                case .lines:
                                    return "Lines in CGA are used in robotics for representing joint axes, in computer vision for line feature detection, and in computer graphics for ray tracing."
                                    
                                case .pointPairs:
                                    return "Point pairs in CGA are used in robotics for representing joints, in computer vision for stereo correspondence, and in physics for modeling dipoles."
                                    
                                case .intersections:
                                    return "The meet operation in CGA is used in computer graphics for ray tracing, in robotics for collision detection, and in computer vision for 3D reconstruction."
                                    
                                case .transformations:
                                    return "Transformations in CGA are used in animation for character rigging, in robotics for inverse kinematics, and in computer vision for camera calibration."
                                    
                                case .applications:
                                    return "CGA has been successfully applied in robotics for motion planning and control, in computer graphics for physics-based animation, in computer vision for 3D reconstruction, and in physics for modeling relativistic phenomena."
                                }
                            }
                            
                            /// Get the steps for the lesson
                            public var steps: [DerivationStep] {
                                switch self {
                                case .introduction:
                                    return [
                                        DerivationStep(latex: "Introduction to Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{CGA extends 3D space with two extra dimensions:}",
                                            explanation: "The conformal model adds two basis vectors to the standard basis."
                                        ),
                                        DerivationStep(
                                            latex: "e_0 \\text{ (origin point) and } e_{\\infty} \\text{ (point at infinity)}",
                                            explanation: "These two additional basis vectors have special properties."
                                        ),
                                        DerivationStep(
                                            latex: "e_0^2 = 0, \\quad e_{\\infty}^2 = 0, \\quad e_0 \\cdot e_{\\infty} = -1",
                                            explanation: "The null basis vectors square to zero and have a specific inner product."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{The 3D conformal space has signature } (4,1)",
                                            explanation: "This means one dimension has a negative square, while four have positive squares."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{This allows us to represent:}",
                                            explanation: "The conformal model can efficiently represent various geometric entities."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Points, Spheres, Planes, Circles, Lines, Point Pairs, ...}",
                                            explanation: "All these entities are represented as multivectors in CGA."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{And perform transformations like:}",
                                            explanation: "Transformations in CGA have an elegant form."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Rotations, Translations, Dilations, ...}",
                                            explanation: "All these transformations can be represented as versors in CGA."
                                        )
                                    ]
                                    
                                case .points:
                                    return [
                                        DerivationStep(latex: "Points in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{Starting with a 3D point } \\vec{p} = (x, y, z)",
                                            explanation: "We begin with a standard Euclidean point."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{In CGA, this point is represented by:}",
                                            explanation: "The conformal representation maps a 3D point to a 5D null vector."
                                        ),
                                        DerivationStep(
                                            latex: "P = e_0 + \\vec{p} + \\frac{1}{2}\\vec{p}^2e_{\\infty}",
                                            explanation: "This is the conformal embedding of the point."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{This multivector has the property that } P^2 = 0",
                                            explanation: "The square of a conformal point is zero, making it a null vector."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{The inner product between two points encodes their distance:}",
                                            explanation: "This is one of the key features of the conformal model."
                                        ),
                                        DerivationStep(
                                            latex: "P_1 \\cdot P_2 = -\\frac{1}{2}|\\vec{p}_1 - \\vec{p}_2|^2",
                                            explanation: "The Euclidean distance is encoded in the inner product."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{This allows for computing distances without coordinates}",
                                            explanation: "One of the advantages of using CGA for geometry."
                                        )
                                    ]
                                    
                                case .spheres:
                                    return [
                                        DerivationStep(latex: "Spheres in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{A sphere is defined by its center } c \\text{ and radius } r",
                                            explanation: "The standard parameters of a sphere."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{In CGA, a sphere can be represented in dual form:}",
                                            explanation: "The dual form makes testing for point containment simple."
                                        ),
                                        DerivationStep(
                                            latex: "s^* = c - \\frac{1}{2}r^2e_{\\infty}",
                                            explanation: "c is the conformal representation of the center, and r is the radius."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A point } P \\text{ lies on the sphere if and only if } P \\cdot s^* = 0",
                                            explanation: "This provides a simple test for containment."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{We can also represent a sphere as the wedge of 4 points:}",
                                            explanation: "This is the direct form of a sphere."
                                        ),
                                        DerivationStep(
                                            latex: "s = P_1 \\wedge P_2 \\wedge P_3 \\wedge P_4",
                                            explanation: "The four points must lie on the sphere."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{The dual of a sphere is its center minus half the squared radius:}",
                                            explanation: "This relates the direct and dual forms."
                                        ),
                                        DerivationStep(
                                            latex: "s^* = c - \\frac{1}{2}r^2e_{\\infty} \\iff s = (c - \\frac{1}{2}r^2e_{\\infty}) \\cdot I^{-1}",
                                            explanation: "I is the pseudoscalar of the conformal space."
                                        )
                                    ]
                                    
                                case .planes:
                                    return [
                                        DerivationStep(latex: "Planes in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{A plane is defined by its normal } n \\text{ and distance } d",
                                            explanation: "The standard parameters of a plane in 3D space."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{In CGA, a plane can be represented in dual form:}",
                                            explanation: "The dual form makes testing for point containment simple."
                                        ),
                                        DerivationStep(
                                            latex: "\\pi^* = n + de_{\\infty}",
                                            explanation: "n is the normal vector and d is the distance from the origin."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A point } P \\text{ lies on the plane if and only if } P \\cdot \\pi^* = 0",
                                            explanation: "This provides a simple test for containment."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{We can also represent a plane as:}",
                                            explanation: "This is the direct form of a plane."
                                        ),
                                        DerivationStep(
                                            latex: "\\pi = P_1 \\wedge P_2 \\wedge P_3 \\wedge e_{\\infty}",
                                            explanation: "The three points must lie on the plane."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A plane can be seen as a sphere with infinite radius}",
                                            explanation: "This illustrates the unification of geometric entities in CGA."
                                        )
                                    ]
                                    
                                case .circles:
                                    return [
                                        DerivationStep(latex: "Circles in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{A circle is defined by its center, radius, and normal vector}",
                                            explanation: "These parameters uniquely define a circle in 3D space."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{In CGA, a circle can be represented as:}",
                                            explanation: "A circle is the intersection of a sphere and a plane."
                                        ),
                                        DerivationStep(
                                            latex: "z = s^* \\wedge \\pi^*",
                                            explanation: "The wedge product of the dual forms of a sphere and a plane."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{We can also represent a circle as:}",
                                            explanation: "This is the direct form of a circle."
                                        ),
                                        DerivationStep(
                                            latex: "z = P_1 \\wedge P_2 \\wedge P_3",
                                            explanation: "The three points must lie on the circle."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A point } P \\text{ lies on the circle if and only if } P \\wedge z = 0",
                                            explanation: "This provides a simple test for containment."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Circles can degenerate into point pairs or a single point}",
                                            explanation: "When a sphere and plane intersect tangentially or don't intersect."
                                        )
                                    ]
                                    
                                case .lines:
                                    return [
                                        DerivationStep(latex: "Lines in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{A line is defined by its direction and a point on the line}",
                                            explanation: "These parameters uniquely define a line in 3D space."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{In CGA, a line can be represented as:}",
                                            explanation: "A line passes through two points and extends to infinity."
                                        ),
                                        DerivationStep(
                                            latex: "L = P_1 \\wedge P_2 \\wedge e_{\\infty}",
                                            explanation: "The wedge product of two points and the point at infinity."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{We can also represent a line as:}",
                                            explanation: "A line is the intersection of two planes."
                                        ),
                                        DerivationStep(
                                            latex: "L = \\pi_1^* \\wedge \\pi_2^*",
                                            explanation: "The wedge product of the dual forms of two planes."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A point } P \\text{ lies on the line if and only if } P \\wedge L = 0",
                                            explanation: "This provides a simple test for containment."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Lines can be represented using Plücker coordinates}",
                                            explanation: "The CGA representation is equivalent to Plücker coordinates."
                                        )
                                    ]
                                    
                                case .pointPairs:
                                    return [
                                        DerivationStep(latex: "Point Pairs in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{A point pair represents two points as a single entity}",
                                            explanation: "This is useful for representing line segments or intervals."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{In CGA, a point pair can be represented as:}",
                                            explanation: "The direct form of a point pair."
                                        ),
                                        DerivationStep(
                                            latex: "Pp = P_1 \\wedge P_2",
                                            explanation: "The wedge product of two conformal points."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A point pair can also be seen as:}",
                                            explanation: "Point pairs have multiple interpretations."
                                        ),
                                        DerivationStep(
                                            latex: "Pp = L \\wedge s^*",
                                            explanation: "The intersection of a line and a sphere."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Or as a degenerate circle:}",
                                            explanation: "A circle with zero radius."
                                        ),
                                        DerivationStep(
                                            latex: "Pp = P_1 \\wedge P_2 \\wedge P_3 \\text{ where the points are collinear}",
                                            explanation: "When three points are collinear, their wedge product is a point pair."
                                        )
                                    ]
                                    
                                case .intersections:
                                    return [
                                        DerivationStep(latex: "Intersections in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{CGA provides a unified way to compute intersections}",
                                            explanation: "This is one of the advantages of CGA for geometric computing."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{The meet operation computes the intersection of two entities:}",
                                            explanation: "The meet is the dual of the wedge of the duals."
                                        ),
                                        DerivationStep(
                                            latex: "A \\vee B = (\\tilde{A} \\wedge \\tilde{B})^{\\sim}",
                                            explanation: "Where ~ denotes the dual operation."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{For example, the intersection of a sphere and a plane:}",
                                            explanation: "This produces a circle or a point."
                                        ),
                                        DerivationStep(
                                            latex: "s \\vee \\pi = (s^* \\wedge \\pi^*)^{\\sim} = z^{\\sim}",
                                            explanation: "The result is a circle in its dual form."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{And the intersection of two spheres:}",
                                            explanation: "This produces a circle."
                                        ),
                                        DerivationStep(
                                            latex: "s_1 \\vee s_2 = (s_1^* \\wedge s_2^*)^{\\sim}",
                                            explanation: "The result is a circle in its dual form."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{The meet operation works for all geometric entities in CGA}",
                                            explanation: "Providing a unified approach to intersection problems."
                                        )
                                    ]
                                    
                                case .transformations:
                                    return [
                                        DerivationStep(latex: "Transformations in Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{CGA provides a unified way to represent transformations}",
                                            explanation: "This is one of the key advantages of CGA."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Transformations are represented by versors:}",
                                            explanation: "Versors are multivectors that can be expressed as geometric products of vectors."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A transformation is applied using the sandwich product:}",
                                            explanation: "This is how versors act on multivectors."
                                        ),
                                        DerivationStep(
                                            latex: "X' = V X V^{-1}",
                                            explanation: "Where V is the versor representing the transformation."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{For example, a translation by vector } t \\text{ is:}",
                                            explanation: "Translations in CGA have a simple form."
                                        ),
                                        DerivationStep(
                                            latex: "T = 1 - \\frac{1}{2}te_{\\infty}",
                                            explanation: "This is the versor representing a translation."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{A rotation by angle } \\theta \\text{ around axis } l \\text{ is:}",
                                            explanation: "Rotations are represented by rotors."
                                        ),
                                        DerivationStep(
                                            latex: "R = e^{-\\frac{\\theta}{2}l}",
                                            explanation: "This is the rotor representing a rotation."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{And a dilation by factor } \\alpha \\text{ is:}",
                                            explanation: "Dilations are also represented by versors."
                                        ),
                                        DerivationStep(
                                            latex: "D = e^{-\\frac{\\ln \\alpha}{2}e_0 \\wedge e_{\\infty}}",
                                            explanation: "This is the versor representing a dilation."
                                        )
                                    ]
                                    
                                case .applications:
                                    return [
                                        DerivationStep(latex: "Applications of Conformal Geometric Algebra", isHeader: true),
                                        DerivationStep(
                                            latex: "\\text{Computer Graphics:}",
                                            explanation: "CGA is used in computer graphics for various purposes."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- Ray tracing and intersection computation}",
                                            explanation: "The meet operation is particularly useful here."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- Character animation and skinning}",
                                            explanation: "The unified representation of transformations is beneficial."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Robotics:}",
                                            explanation: "CGA has applications in robotics."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- Inverse kinematics}",
                                            explanation: "The conformal model simplifies the computation of inverse kinematics."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- Path planning and obstacle avoidance}",
                                            explanation: "CGA provides elegant ways to represent paths and obstacles."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Computer Vision:}",
                                            explanation: "CGA is used in computer vision for various tasks."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- Camera calibration}",
                                            explanation: "The conformal model provides an elegant way to represent cameras."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- 3D reconstruction}",
                                            explanation: "CGA's unified approach to geometry is beneficial here."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{Physics:}",
                                            explanation: "CGA has applications in physics as well."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- Relativistic physics}",
                                            explanation: "The conformal model can represent Minkowski space."
                                        ),
                                        DerivationStep(
                                            latex: "\\text{- Quantum mechanics}",
                                            explanation: "CGA provides a geometric interpretation of quantum phenomena."
                                        )
                                    ]
                                }
                            }
                        }

                        /// Different intersection types for the intersection lesson
                        public enum IntersectionType {
                            case spherePlane
                            case sphereSphere
                            case planeLine
                        }

                        /// Different applications for the applications lesson
                        public enum ApplicationType {
                            case cameraModel
                            case rigidBody
                            case collisionDetection
                        }

                        /// Different transformation types for the transformation lesson
                        public enum TransformationType {
                            case translation
                            case rotation
                            case dilation
                        }

                        /// Different transformation objects for the transformation lesson
                        public enum TransformObject {
                            case sphere
                            case line
                            case pointPair
                        }

                        /// Different rigid body types for the rigid body application
                        public enum RigidBodyType {
                            case cube
                            case sphere
                            case cylinder
                        }

                        /// Parameters for the current lesson
                        public struct LessonParameters {
                            // Shared parameters
                            var point = SIMD3<Double>(1, 1, 1)
                            
                            // Sphere parameters
                            var sphereCenter = SIMD3<Double>(0, 0, 0)
                            var sphereRadius: Double = 1.0
                            
                            // Plane parameters
                            var planeNormal = SIMD3<Double>(0, 1, 0)
                            var planeDistance: Double = 0.0
                            
                            // Circle parameters
                            var circleCenter = SIMD3<Double>(0, 0, 0)
                            var circleRadius: Double = 1.0
                            var circleNormal = SIMD3<Double>(0, 1, 0)
                            
                            // Line parameters
                            var linePoint1 = SIMD3<Double>(-1, 0, 0)
                            var linePoint2 = SIMD3<Double>(1, 0, 0)
                            
                            // Point pair parameters
                            var pairPoint1 = SIMD3<Double>(-1, 0, 0)
                            var pairPoint2 = SIMD3<Double>(1, 0, 0)
                            
                            // Intersection parameters
                            var intersectionType: IntersectionType = .spherePlane
                            var sphere1Center = SIMD3<Double>(-0.5, 0, 0)
                            var sphere1Radius: Double = 1.0
                            var sphere2Center = SIMD3<Double>(0.5, 0, 0)
                            var sphere2Radius: Double = 1.0
                            
                            // Transformation parameters
                            var transformationType: TransformationType = .translation
                            var transformObject: TransformObject = .sphere
                            var translation = SIMD3<Double>(1, 0, 0)
                            var rotationAxis = SIMD3<Double>(0, 1, 0)
                            var rotationAngle: Double = Double.pi / 4
                            var scaleFactor: Double = 1.5
                            var scaleCenter = SIMD3<Double>(0, 0, 0)
                            
                            // Application parameters
                            var applicationType: ApplicationType = .cameraModel
                            var cameraPosition = SIMD3<Double>(0, 0, 5)
                            var lookAtPoint = SIMD3<Double>(0, 0, 0)
                            var rigidBodyType: RigidBodyType = .cube
                            var rigidBodyPosition = SIMD3<Double>(0, 0, 0)
                            var rigidBodyRotation: Double = 0
                            var collision1Position = SIMD3<Double>(-0.5, 0, 0)
                            var collision1Radius: Double = 1.0
                            var collision2Position = SIMD3<Double>(0.5, 0, 0)
                            var collision2Radius: Double = 1.0
                        }
                                            thickness: 0.05,
                                            name: "Intersection"
                                        )
                                        entityIDs["intersection"] = circleID
                                    }
                                    
                                case .planeLine:
                                    // Add the plane
                                    let normal = simd_normalize(lessonParameters.planeNormal)
                                    let planeID = visualizer.addPlane(
                                        normal: normal,
                                        distance: lessonParameters.planeDistance,
                                        size: 5.0,
                                        color: NSColor.blue,
                                        opacity: 0.3,
                                        name: "Plane"
                                    )
                                    entityIDs["plane"] = planeID
                                    
                                    // Add the line
                                    let lineID = visualizer.addLine(
                                        from: lessonParameters.linePoint1,
                                        to: lessonParameters.linePoint2,
                                        color: NSColor.green,
                                        thickness: 0.05,
                                        name: "Line"
                                    )
                                    entityIDs["line"] = lineID
                                    
                                    // Calculate the intersection point
                                    let lineVector = lessonParameters.linePoint2 - lessonParameters.linePoint1
                                    let lineDirection = simd_normalize(lineVector)
                                    
                                    // Calculate the point on the plane
                                    let planePoint = normal * lessonParameters.planeDistance
                                    
                                    // Check if line is parallel to plane
                                    let dotProduct = simd_dot(normal, lineDirection)
                                    
                                    if abs(dotProduct) > 1e-6 {
                                        // Line intersects the plane
                                        // Calculate parameter t where the line intersects the plane
                                        let t = simd_dot(normal, planePoint - lessonParameters.linePoint1) / dotProduct
                                        
                                        // Calculate the intersection point
                                        let intersectionPoint = lessonParameters.linePoint1 + lineDirection * t
                                        
                                        // Add the intersection point
                                        let pointID = visualizer.addPoint(
                                            position: intersectionPoint,
                                            color: NSColor.red,
                                            size: 0.15,
                                            name: "Intersection"
                                        )
                                        entityIDs["intersection"] = pointID
                                    }
                                }
                            }
                            
                            /// Visualize the transformations lesson
                            private func visualizeTransformations() {
                                // Create the original object based on selected type
                                switch lessonParameters.transformObject {
                                case .sphere:
                                    // Add the original sphere
                                    let sphereID = visualizer.addSphere(
                                        center: lessonParameters.sphereCenter,
                                        radius: lessonParameters.sphereRadius,
                                        color: NSColor.blue,
                                        opacity: 0.3,
                                        name: "Original"
                                    )
                                    entityIDs["original"] = sphereID
                                    
                                    // Create transformed object
                                    let transformedCenter: SIMD3<Double>
                                    let transformedRadius: Double
                                    
                                    switch lessonParameters.transformationType {
                                    case .translation:
                                        // Translate the sphere
                                        transformedCenter = lessonParameters.sphereCenter + lessonParameters.translation
                                        transformedRadius = lessonParameters.sphereRadius
                                        
                                        // Add a vector showing the translation
                                        let vectorID = visualizer.addVector(
                                            from: lessonParameters.sphereCenter,
                                            to: transformedCenter,
                                            color: NSColor.yellow,
                                            thickness: 0.03,
                                            name: "Translation"
                                        )
                                        entityIDs["translationVector"] = vectorID
                                        
                                    case .rotation:
                                        // Get rotation axis and angle
                                        let axis = simd_normalize(lessonParameters.rotationAxis)
                                        let angle = lessonParameters.rotationAngle
                                        
                                        // Create the rotation matrix
                                        let rotationMatrix = createRotationMatrix(axis: axis, angle: angle)
                                        
                                        // Apply the rotation to the center
                                        transformedCenter = mul(rotationMatrix, lessonParameters.sphereCenter)
                                        transformedRadius = lessonParameters.sphereRadius
                                        
                                        // Add the rotation axis
                                        let axisID = visualizer.addVector(
                                            from: SIMD3<Double>.zero,
                                            to: axis * 3.0,
                                            color: NSColor.yellow,
                                            thickness: 0.03,
                                            name: "Axis"
                                        )
                                        entityIDs["rotationAxis"] = axisID
                                        
                                    case .dilation:
                                        // Dilate the sphere from a center
                                        let scaleCenter = lessonParameters.scaleCenter
                                        let scaleFactor = lessonParameters.scaleFactor
                                        
                                        // Calculate transformed center and radius
                                        transformedCenter = scaleCenter + (lessonParameters.sphereCenter - scaleCenter) * scaleFactor
                                        transformedRadius = lessonParameters.sphereRadius * scaleFactor
                                        
                                        // Add scale center point
                                        let centerID = visualizer.addPoint(
                                            position: scaleCenter,
                                            color: NSColor.yellow,
                                            size: 0.1,
                                            name: "Scale Center"
                                        )
                                        entityIDs["scaleCenter"] = centerID
                                    }
                                    
                                    // Add the transformed sphere
                                    let transformedID = visualizer.addSphere(
                                        center: transformedCenter,
                                        radius: transformedRadius,
                                        color: NSColor.red,
                                        opacity: 0.3,
                                        name: "Transformed"
                                    )
                                    entityIDs["transformed"] = transformedID
                                    
                                case .line:
                                    // Add the original line
                                    let lineID = visualizer.addLine(
                                        from: lessonParameters.linePoint1,
                                        to: lessonParameters.linePoint2,
                                        color: NSColor.green,
                                        thickness: 0.05,
                                        name: "Original"
                                    )
                                    entityIDs["original"] = lineID
                                    
                                    // Create transformed line
                                    var transformedPoint1: SIMD3<Double>
                                    var transformedPoint2: SIMD3<Double>
                                    
                                    switch lessonParameters.transformationType {
                                    case .translation:
                                        // Translate the line
                                        transformedPoint1 = lessonParameters.linePoint1 + lessonParameters.translation
                                        transformedPoint2 = lessonParameters.linePoint2 + lessonParameters.translation
                                        
                                        // Add a vector showing the translation
                                        let vectorID = visualizer.addVector(
                                            from: lessonParameters.linePoint1,
                                            to: transformedPoint1,
                                            color: NSColor.yellow,
                                            thickness: 0.03,
                                            name: "Translation"
                                        )
                                        entityIDs["translationVector"] = vectorID
                                        
                                    case .rotation:
                                        // Get rotation axis and angle
                                        let axis = simd_normalize(lessonParameters.rotationAxis)
                                        let angle = lessonParameters.rotationAngle
                                        
                                        // Create the rotation matrix
                                        let rotationMatrix = createRotationMatrix(axis: axis, angle: angle)
                                        
                                        // Apply the rotation to the line points
                                        transformedPoint1 = mul(rotationMatrix, lessonParameters.linePoint1)
                                        transformedPoint2 = mul(rotationMatrix, lessonParameters.linePoint2)
                                        
                                        // Add the rotation axis
                                        let axisID = visualizer.addVector(
                                            from: SIMD3<Double>.zero,
                                            to: axis * 3.0,
                                            color: NSColor.yellow,
                                            thickness: 0.03,
                                            name: "Axis"
                                        )
                                        entityIDs["rotationAxis"] = axisID
                                        
                                    case .dilation:
                                        // Dilate the line from a center
                                        let scaleCenter = lessonParameters.scaleCenter
                                        let scaleFactor = lessonParameters.scaleFactor
                                        
                                        // Calculate transformed points
                                        transformedPoint1 = scaleCenter + (lessonParameters.linePoint1 - scaleCenter) * scaleFactor
                                        transformedPoint2 = scaleCenter + (lessonParameters.linePoint2 - scaleCenter) * scaleFactor
                                        
                                        // Add scale center point
                                        let centerID = visualizer.addPoint(
                                            position: scaleCenter,
                                            color: NSColor.yellow,
                                            size: 0.1,
                                            name: "Scale Center"
                                        )
                                        entityIDs["scaleCenter"] = centerID
                                    }
                                    
                                    // Add the transformed line
                                    let transformedID = visualizer.addLine(
                                        from: transformedPoint1,
                                        to: transformedPoint2,
                                        color: NSColor.red,
                                        thickness: 0.05,
                                        name: "Transformed"
                                    )
                                    entityIDs["transformed"] = transformedID
                                    
                                case .pointPair:
                                    // Add the original point pair
                                    let point1ID = visualizer.addPoint(
                                        position: lessonParameters.pairPoint1,
                                        color: NSColor.blue,
                                        size: 0.1,
                                        name: "P₁"
                                    )
                                    entityIDs["point1"] = point1ID
                                    
                                    let point2ID = visualizer.addPoint(
                                        position: lessonParameters.pairPoint2,
                                        color: NSColor.blue,
                                        size: 0.1,
                                        name: "P₂"
                                    )
                                    entityIDs["point2"] = point2ID
                                    
                                    let lineID = visualizer.addLine(
                                        from: lessonParameters.pairPoint1,
                                        to: lessonParameters.pairPoint2,
                                        color: NSColor.green,
                                        thickness: 0.03,
                                        name: "Original"
                                    )
                                    entityIDs["originalLine"] = lineID
                                    
                                    // Create transformed point pair
                                    var transformedPoint1: SIMD3<Double>
                                    var transformedPoint2: SIMD3<Double>
                                    
                                    switch lessonParameters.transformationType {
                                    case .translation:
                                        // Translate the points
                                        transformedPoint1 = lessonParameters.pairPoint1 + lessonParameters.translation
                                        transformedPoint2 = lessonParameters.pairPoint2 + lessonParameters.translation
                                        
                                        // Add a vector showing the translation
                                        let vectorID = visualizer.addVector(
                                            from: lessonParameters.pairPoint1,
                                            to: transformedPoint1,
                                            color: NSColor.yellow,
                                            thickness: 0.03,
                                            name: "Translation"
                                        )
                                        entityIDs["translationVector"] = vectorID
                                        
                                    case .rotation:
                                        // Get rotation axis and angle
                                        let axis = simd_normalize(lessonParameters.rotationAxis)
                                        let angle = lessonParameters.rotationAngle
                                        
                                        // Create the rotation matrix
                                        let rotationMatrix = createRotationMatrix(axis: axis, angle: angle)
                                        
                                        // Apply the rotation to the points
                                        transformedPoint1 = mul(rotationMatrix, lessonParameters.pairPoint1)
                                        transformedPoint2 = mul(rotationMatrix, lessonParameters.pairPoint2)
                                        
                                        // Add the rotation axis
                                        let axisID = visualizer.addVector(
                                            from: SIMD3<Double>.zero,
                                            to: axis * 3.0,
                                            color: NSColor.yellow,
                                            thickness: 0.03,
                                            name: "Axis"
                                        )
                                        entityIDs["rotationAxis"] = axisID
                                        
                                    case .dilation:
                                        // Dilate the point pair from a center
                                        let scaleCenter = lessonParameters.scaleCenter
                                        let scaleFactor = lessonParameters.scaleFactor
                                        
                                        // Calculate transformed points
                                        transformedPoint1 = scaleCenter + (lessonParameters.pairPoint1 - scaleCenter) * scaleFactor
                                        transformedPoint2 = scaleCenter + (lessonParameters.pairPoint2 - scaleCenter) * scaleFactor
                                        
                                        // Add scale center point
                                        let centerID = visualizer.addPoint(
                                            position: scaleCenter,
                                            color: NSColor.yellow,
                                            size: 0.1,
                                            name: "Scale Center"
                                        )
                                        entityIDs["scaleCenter"] = centerID
                                    }
                                    
                                    // Add the transformed points
                                    let tPoint1ID = visualizer.addPoint(
                                        position: transformedPoint1,
                                        color: NSColor.red,
                                        size: 0.1,
                                        name: "P₁'"
                                    )
                                    entityIDs["tPoint1"] = tPoint1ID
                                    
                                    let tPoint2ID = visualizer.addPoint(
                                        position: transformedPoint2,
                                        color: NSColor.red,
                                        size: 0.1,
                                        name: "P₂'"
                                    )
                                    entityIDs["tPoint2"] = tPoint2ID
                                    
                                    // Add the transformed line
                                    let transformedLineID = visualizer.addLine(
                                        from: transformedPoint1,
                                        to: transformedPoint2,
                                        color: NSColor.red,
                                        thickness: 0.03,
                                        name: "Transformed"
                                    )
                                    entityIDs["transformedLine"] = transformedLineID
                                }
                            }
                            
                            /// Visualize the applications lesson
                            private func visualizeApplications() {
                                switch lessonParameters.applicationType {
                                case .cameraModel:
                                    // Add a camera representation
                                    let cameraPos = lessonParameters.cameraPosition
                                    let lookAt = lessonParameters.lookAtPoint
                                    
                                    // Add camera point
                                    let cameraID = visualizer.addPoint(
                                        position: cameraPos,
                                        color: NSColor.yellow,
                                        size: 0.15,
                                        name: "Camera"
                                    )
                                    entityIDs["camera"] = cameraID
                                    
                                    // Add look-at point
                                    let lookAtID = visualizer.addPoint(
                                        position: lookAt,
                                        color: NSColor.green,
                                        size: 0.1,
                                        name: "Look-At"
                                    )
                                    entityIDs["lookAt"] = lookAtID
                                    
                                    // Add viewing direction vector
                                    let viewDirID = visualizer.addVector(
                                        from: cameraPos,
                                        to: lookAt,
                                        color: NSColor.blue,
                                        thickness: 0.03,
                                        name: "View Direction"
                                    )
                                    entityIDs["viewDir"] = viewDirID
                                    
                                    // Calculate view plane
                                    let viewDir = simd_normalize(lookAt - cameraPos)
                                    let distance = simd_length(lookAt - cameraPos)
                                    
                                    // Add view plane
                                    let planeID = visualizer.addPlane(
                                        normal: viewDir,
                                        distance: simd_dot(viewDir, lookAt),
                                        size: 3.0,
                                        color: NSColor.cyan,
                                        opacity: 0.2,
                                        name: "Image Plane"
                                    )
                                    entityIDs["viewPlane"] = planeID
                                    
                                    // Add some test objects in the scene
                                    let sphere1ID = visualizer.addSphere(
                                        center: SIMD3<Double>(2, 1, -3),
                                        radius: 0.5,
                                        color: NSColor.red,
                                        opacity: 0.3,
                                        name: "Object 1"
                                    )
                                    entityIDs["object1"] = sphere1ID
                                    
                                    let sphere2ID = visualizer.addSphere(
                                        center: SIMD3<Double>(-1, 0, -2),
                                        radius: 0.7,
                                        color: NSColor.purple,
                                        opacity: 0.3,
                                        name: "Object 2"
                                    )
                                    entityIDs["object2"] = sphere2ID
                                    
                                case .rigidBody:
                                    // Add a rigid body representation
                                    let position = lessonParameters.rigidBodyPosition
                                    let rotation = lessonParameters.rigidBodyRotation
                                    
                                    // Create a reference coordinate system
                                    let xAxisID = visualizer.addVector(
                                        from: SIMD3<Double>.zero,
                                        to: SIMD3<Double>(1, 0, 0),
                                        color: NSColor.red,
                                        thickness: 0.02,
                                        name: "X"
                                    )
                                    entityIDs["xAxis"] = xAxisID
                                    
                                    let yAxisID = visualizer.addVector(
                                        from: SIMD3<Double>.zero,
                                        to: SIMD3<Double>(0, 1, 0),
                                        color: NSColor.green,
                                        thickness: 0.02,
                                        name: "Y"
                                    )
                                    entityIDs["yAxis"] = yAxisID
                                    
                                    let zAxisID = visualizer.addVector(
                                        from: SIMD3<Double>.zero,
                                        to: SIMD3<Double>(0, 0, 1),
                                        color: NSColor.blue,
                                        thickness: 0.02,
                                        name: "Z"
                                    )
                                    entityIDs["zAxis"] = zAxisID
                                    
                                    // Create rotated coordinate system
                                    let rotMatrix = createRotationMatrix(axis: SIMD3<Double>(0, 1, 0), angle: rotation)
                                    
                                    let rotXID = visualizer.addVector(
                                        from: position,
                                        to: position + mul(rotMatrix, SIMD3<Double>(1, 0, 0)),
                                        color: NSColor.red,
                                        thickness: 0.03,
                                        name: "X'"
                                    )
                                    entityIDs["rotX"] = rotXID
                                    
                                    let rotYID = visualizer.addVector(
                                        from: position,
                                        to: position + mul(rotMatrix, SIMD3<Double>(0, 1, 0)),
                                        color: NSColor.green,
                                        thickness: 0.03,
                                        name: "Y'"
                                    )
                                    entityIDs["rotY"] = rotYID
                                    
                                    let rotZID = visualizer.addVector(
                                        from: position,
                                        to: position + mul(rotMatrix, SIMD3<Double>(0, 0, 1)),
                                        color: NSColor.blue,
                                        thickness: 0.03,
                                        name: "Z'"
                                    )
                                    entityIDs["rotZ"] = rotZID
                                    
                                    // Draw the rigid body based on its type
                                    switch lessonParameters.rigidBodyType {
                                    case .cube:
                                        // Create a simplified cube representation using lines
                                        let size = 0.5
                                        let corners = [
                                            SIMD3<Double>(-size, -size, -size),
                                            SIMD3<Double>(size, -size, -size),
                                            SIMD3<Double>(size, size, -size),
                                            SIMD3<Double>(-size, size, -size),
                                            SIMD3<Double>(-size, -size, size),
                                            SIMD3<Double>(size, -size, size),
                                            SIMD3<Double>(size, size, size),
                                            SIMD3<Double>(-size, size, size)
                                        ]
                                        
                                        // Transform corners
                                        let transformedCorners = corners.map { corner in
                                            position + mul(rotMatrix, corner)
                                        }
                                        
                                        // Create edges
                                        let edges = [
                                            (0, 1), (1, 2), (2, 3), (3, 0),
                                            (4, 5), (5, 6), (6, 7), (7, 4),
                                            (0, 4), (1, 5), (2, 6), (3, 7)
                                        ]
                                        
                                        for (i, edge) in edges.enumerated() {
                                            let lineID = visualizer.addLine(
                                                from: transformedCorners[edge.0],
                                                to: transformedCorners[edge.1],
                                                color: NSColor.orange,
                                                thickness: 0.02,
                                                name: nil
                                            )
                                            entityIDs["edge\(i)"] = lineID
                                        }
                                        
                                    case .sphere:
                                        let sphereID = visualizer.addSphere(
                                            center: position,
                                            radius: 0.5,
                                            color: NSColor.orange,
                                            opacity: 0.5,
                                            name: "Rigid Body"
                                        )
                                        entityIDs["rigidBody"] = sphereID
                                        
                                    case .cylinder:
                                        // Add a point for the cylinder position
                                        let centerID = visualizer.addPoint(
                                            position: position,
                                            color: NSColor.yellow,
                                            size: 0.1,
                                            name: "Center"
                                        )
                                        entityIDs["cylinderCenter"] = centerID
                                        
                                        // Add a circle to represent the cylinder top
                                        let topCenter = position + mul(rotMatrix, SIMD3<Double>(0, 0.5, 0))
                                        let topID = visualizer.addCircle(
                                            center: topCenter,
                                            radius: 0.3,
                                            normal: mul(rotMatrix, SIMD3<Double>(0, 1, 0)),
                                            color: NSColor.orange,
                                            thickness: 0.03,
                                            name: "Top"
                                        )
                                        entityIDs["cylinderTop"] = topID
                                        
                                        // Add a circle to represent the cylinder bottom
                                        let bottomCenter = position + mul(rotMatrix, SIMD3<Double>(0, -0.5, 0))
                                        let bottomID = visualizer.addCircle(
                                            center: bottomCenter,
                                            radius: 0.3,
                                            normal: mul(rotMatrix, SIMD3<Double>(0, 1, 0)),
                                            color: NSColor.orange,
                                            thickness: 0.03,
                                            name: "Bottom"
                                        )
                                        entityIDs["cylinderBottom"] = bottomID
                                        
                                        // Add lines connecting the top and bottom circles
                                        for i in 0..<4 {
                                            let angle = Double(i) * Double.pi / 2.0
                                            let x = 0.3 * cos(angle)
                                            let z = 0.3 * sin(angle)
                                            
                                            let topPoint = topCenter + mul(rotMatrix, SIMD3<Double>(x, 0, z))
                                            let bottomPoint = bottomCenter + mul(rotMatrix, SIMD3<Double>(x, 0, z))
                                            
                                            let lineID = visualizer.addLine(
                                                from: topPoint,
                                                to: bottomPoint,
                                                color: NSColor.orange,
                                                thickness: 0.02,
                                                name: nil
                                            )
                                            entityIDs["cylinderLine\(i)"] = lineID
                                        }
                                    }
                                    
                                case .collisionDetection:
                                    // Add the two colliding objects
                                    let sphere1ID = visualizer.addSphere(
                                        center: lessonParameters.collision1Position,
                                        radius: lessonParameters.collision1Radius,
                                        color: NSColor.red,
                                        opacity: 0.3,
                                        name: "Object 1"
                                    )
                                    entityIDs["object1"] = sphere1ID
                                    
                                    let sphere2ID = visualizer.addSphere(
                                        center: lessonParameters.collision2Position,
                                        radius: lessonParameters.collision2Radius,
                                        color: NSColor.blue,
                                        opacity: 0.3,
                                        name: "Object 2"
                                    )
                                    entityIDs["object2"] = sphere2ID
                                    
                                    // Calculate distance between spheres
                                    let distance = simd_distance(lessonParameters.collision1Position, lessonParameters.collision2Position)
                                    let sumOfRadii = lessonParameters.collision1Radius + lessonParameters.collision2Radius
                                    
                                    // Check for collision
                                    if distance < sumOfRadii {
                                        // Calculate the penetration depth
                                        let penetration = sumOfRadii - distance
                                        
                                        // Find the collision normal
                                        let normal: SIMD3<Double>
                                        if distance > 1e-6 {
                                            normal = simd_normalize(lessonParameters.collision2Position - lessonParameters.collision1Position)
                                        } else {
                                            normal = SIMD3<Double>(0, 1, 0)  // Default if centers are too close
                                        }
                                        
                                        // Calculate the contact point (assuming objects are rigid)
                                        let contactPoint = lessonParameters.collision1Position + normal * (lessonParameters.collision1Radius - penetration * 0.5)
                                        
                                        // Add the contact point
                                        let contactID = visualizer.addPoint(
                                            position: contactPoint,
                                            color: NSColor.yellow,
                                            size: 0.12,
                                            name: "Contact"
                                        )
                                        entityIDs["contact"] = contactID
                                        
                                        // Add the contact normal
                                        let normalID = visualizer.addVector(
                                            from: contactPoint,
                                            to: contactPoint + normal * penetration,
                                            color: NSColor.green,
                                            thickness: 0.03,
                                            name: "Normal"
                                        )
                                        entityIDs["normal"] = normalID
                                        
                                        // Add intersection circle
                                        if distance > 1e-6 {
                                            // Calculate the plane of intersection
                                            // The contact plane passes through the contact point with the normal as its normal
                                            let planeID = visualizer.addPlane(
                                                normal: normal,
                                                distance: simd_dot(normal, contactPoint),
                                                size: 3.0,
                                                color: NSColor.cyan,
                                                opacity: 0.2,
                                                name: "Contact Plane"
                                            )
                                            entityIDs["contactPlane"] = planeID
                                            
                                            // Calculate radius of intersection circle with first sphere
                                            let dist1 = simd_dot(normal, contactPoint - lessonParameters.collision1Position)
                                            let r1 = sqrt(lessonParameters.collision1Radius * lessonParameters.collision1Radius - dist1 * dist1)
                                            
                                            let circleID = visualizer.addCircle(
                                                center: contactPoint,
                                                radius: r1,
                                                normal: normal,
                                                color: NSColor.purple,
                                                thickness: 0.03,
                                                name: "Intersection"
                                            )
                                            entityIDs["intersection"] = circleID
                                        }
                                    } else {
                                        // No collision, show the closest points
                                        let direction = simd_normalize(lessonParameters.collision2Position - lessonParameters.collision1Position)
                                        
                                        let closest1 = lessonParameters.collision1Position + direction * lessonParameters.collision1Radius
                                        let closest2 = lessonParameters.collision2Position - direction * lessonParameters.collision2Radius
                                        
                                        // Add closest points
                                        let point1ID = visualizer.addPoint(
                                            position: closest1,
                                            color: NSColor.yellow,
                                            size: 0.08,
                                            name: "Closest 1"
                                        )
                                        entityIDs["closest1"] = point1ID
                                        
                                        let point2ID = visualizer.addPoint(
                                            position: closest2,
                                            color: NSColor.yellow,
                                            size: 0.08,
                                            name: "Closest 2"
                                        )
                                        entityIDs["closest2"] = point2ID
                                        
                                        // Connect the closest points
                                        let lineID = visualizer.addLine(
                                            from: closest1,
                                            to: closest2,
                                            color: NSColor.green,
                                            thickness: 0.02,
                                            name: "Distance"
                                        )
                                        entityIDs["distanceLine"] = lineID
                                    }
                                }
                            }
                            
                            // MARK: - Matrix Operations
                            
                            /// Create a rotation matrix from an axis and angle
                            /// - Parameters:
                            ///   - axis: The rotation axis
                            ///   - angle: The rotation angle
                            /// - Returns: A 3x3 rotation matrix
                            private func createRotationMatrix(axis: SIMD3<Double>, angle: Double) -> simd_double3x3 {
                                let x = axis.x
                                let y = axis.y
                                let z = axis.z
                                let c = cos(angle)
                                let s = sin(angle)
                                let t = 1 - c
                                
                                return simd_double3x3(
                                    SIMD3<Double>(t*x*x + c, t*x*y + s*z, t*x*z - s*y),
                                    SIMD3<Double>(t*x*y - s*z, t*y*y + c, t*y*z + s*x),
                                    SIMD3<Double>(t*x*z + s*y, t*y*z - s*x, t*z*z + c)
                                )
                            }
                            
                            /// Multiply a matrix by a vector
                            /// - Parameters:
                            ///   - matrix: The 3x3 matrix
                            ///   - vector: The 3D vector
                            /// - Returns: The resulting vector
                            private func mul(_ matrix: simd_double3x3, _ vector: SIMD3<Double>) -> SIMD3<Double> {
                                return SIMD3<Double>(
                                    simd_dot(matrix.columns.0, vector),
                                    simd_dot(matrix.columns.1, vector),
                                    simd_dot(matrix.columns.2, vector)
                                )
                            }
                        }

                        // MARK: - Supporting Types

                        /// Lessons available in the CGA learning module
                        public enum CGALesson: String, CaseIterable, Identifiable {
                            case introduction
                            case points
                            case spheres
                            case planes
                            case circles
                            case lines
                            case pointPairs
                            case intersections
                            case transformations
                            case applications
                            
                            public var id: String { self.rawValue }
                            
                            /// Get the title of the lesson
                            public var title: String {
                                switch self {
                                case .introduction: return "Introduction to CGA"
                                case .points: return "Points in CGA"
                                case .spheres: return "Spheres"
                                case .planes: return "Planes"
                                case .circles: return "Circles"
                                case .lines: return "Lines"
                                case .pointPairs: return "Point Pairs"
                                case .intersections: return "Intersections"
                                case .transformations: return "Transformations"
                                case .applications: return "Applications"
                                }
                            }
                            
                            /// Get the description of the lesson
                            public var description: String {
                                switch self {
                                case .introduction:
                                    return "Conformal Geometric Algebra (CGA) is a powerful mathematical framework for representing and manipulating geometric entities in 3D space. It extends the standard 3D Geometric Algebra by adding two extra dimensions: one representing the point at infinity (e∞) and another representing the origin (e₀)."
                                    
                                case .points:
                                    return "In CGA, a 3D point p = (x, y, z) is represented by a specific multivector: P = e₀ + p + 0.5p²e∞. This representation allows us to operate on points using the geometric product, making operations like rotations, translations, and reflections unified and elegant."
                                    
                                case .spheres:
                                    return "A sphere in CGA can be represented as the wedge product of 4 points on its surface, or directly using its center c and radius r: s = c - 0.5r²e∞. This dual form makes it easy to perform operations and test for containment."
                                    
                                case .planes:
                                    return "Planes in CGA are represented as the wedge product of 3 points and the point at infinity, or directly using the normal vector n and distance d: π = n + de∞. This unifies the treatment of planes with other geometric entities."
                                    
                                case .circles:
                                    return "Circles in CGA are elegant intersections of spheres and planes. A circle can be represented directly as the wedge product of 3 points, or as the meet of a sphere and a plane."
                                    
                                case .lines:
                                    return "Lines in CGA are formed by the wedge product of 2 points and the point at infinity, or as the meet of 2 planes. This provides a coordinate-free representation that simplifies many geometric operations."
                                    
                                case .pointPairs:
                                    return "Point pairs in CGA represent two points as a single entity, formed by the wedge product of two points. They can also be viewed as a degenerate circle with zero radius."
                                    
                                case .intersections:
                                    return "One of the strengths of CGA is the unified way to compute intersections between different geometric entities using the meet operation. This provides a coordinate-free approach to intersection problems."
                                    
                                case .transformations:
                                    return "Transformations in CGA are performed using versors (multivectors that can be expressed as geometric products of vectors). They provide a unified way to represent rotations, translations, dilations, and more complex transformations."
                                    
                                case .applications:
                                    return "CGA has applications in computer graphics, robotics, computer vision, and physics. Its coordinate-free approach and unified treatment of transformations and geometric entities make it particularly suitable for these fields."
                                }
                                                    case .dilation:
                                                    HStack {
                                                        Text("Scale Factor:")
                                                        Slider(value: $lessonParameters.scaleFactor, in: 0.1...5)
                                                        Text(String(format: "%.1f", lessonParameters.scaleFactor))
                                                            .frame(width: 40, alignment: .trailing)
                                                            .monospacedDigit()
                                                    }
                                                    
                                                    HStack {
                                                        Text("Center X:")
                                                        Slider(value: $lessonParameters.scaleCenter.x, in: -5...5)
                                                        Text(String(format: "%.1f", lessonParameters.scaleCenter.x))
                                                            .frame(width: 40, alignment: .trailing)
                                                            .monospacedDigit()
                                                    }
                                                    
                                                    HStack {
                                                        Text("Center Y:")
                                                        Slider(value: $lessonParameters.scaleCenter.y, in: -5...5)
                                                        Text(String(format: "%.1f", lessonParameters.scaleCenter.y))
                                                            .frame(width: 40, alignment: .trailing)
                                                            .monospacedDigit()
                                                    }
                                                    
                                                    HStack {
                                                        Text("Center Z:")
                                                        Slider(value: $lessonParameters.scaleCenter.z, in: -5...5)
                                                        Text(String(format: "%.1f", lessonParameters.scaleCenter.z))
                                                            .frame(width: 40, alignment: .trailing)
                                                            .monospacedDigit()
                                                    }
                                                }
                                            }
                                            .onChange(of: lessonParameters.transformationType) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.transformObject) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.sphereCenter) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.sphereRadius) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.linePoint1) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.linePoint2) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.pairPoint1) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.pairPoint2) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.translation) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.rotationAxis) { _ in
                                                // Normalize
                                                let length = simd_length(lessonParameters.rotationAxis)
                                                if length > 0 {
                                                    lessonParameters.rotationAxis = lessonParameters.rotationAxis / length
                                                }
                                                updateVisualization()
                                            }
                                            .onChange(of: lessonParameters.rotationAngle) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.scaleFactor) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.scaleCenter) { _ in updateVisualization() }
                                        }
                                        
                                    case .applications:
                                        // Controls for applications lesson
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Application Type")
                                                .font(.subheadline)
                                            
                                            Picker("Application", selection: $lessonParameters.applicationType) {
                                                Text("Camera Model").tag(ApplicationType.cameraModel)
                                                Text("Rigid Body").tag(ApplicationType.rigidBody)
                                                Text("Collision Detection").tag(ApplicationType.collisionDetection)
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                            .padding(.bottom, 8)
                                            
                                            // Application-specific controls
                                            switch lessonParameters.applicationType {
                                            case .cameraModel:
                                                HStack {
                                                    Text("Camera X:")
                                                    Slider(value: $lessonParameters.cameraPosition.x, in: -10...10)
                                                    Text(String(format: "%.1f", lessonParameters.cameraPosition.x))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Camera Y:")
                                                    Slider(value: $lessonParameters.cameraPosition.y, in: -10...10)
                                                    Text(String(format: "%.1f", lessonParameters.cameraPosition.y))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Camera Z:")
                                                    Slider(value: $lessonParameters.cameraPosition.z, in: -10...10)
                                                    Text(String(format: "%.1f", lessonParameters.cameraPosition.z))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Look-At X:")
                                                    Slider(value: $lessonParameters.lookAtPoint.x, in: -10...10)
                                                    Text(String(format: "%.1f", lessonParameters.lookAtPoint.x))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Look-At Y:")
                                                    Slider(value: $lessonParameters.lookAtPoint.y, in: -10...10)
                                                    Text(String(format: "%.1f", lessonParameters.lookAtPoint.y))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Look-At Z:")
                                                    Slider(value: $lessonParameters.lookAtPoint.z, in: -10...10)
                                                    Text(String(format: "%.1f", lessonParameters.lookAtPoint.z))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                            case .rigidBody:
                                                HStack {
                                                    Text("Object Type:")
                                                    Picker("Object", selection: $lessonParameters.rigidBodyType) {
                                                        Text("Cube").tag(RigidBodyType.cube)
                                                        Text("Sphere").tag(RigidBodyType.sphere)
                                                        Text("Cylinder").tag(RigidBodyType.cylinder)
                                                    }
                                                    .pickerStyle(SegmentedPickerStyle())
                                                }
                                                
                                                HStack {
                                                    Text("Position X:")
                                                    Slider(value: $lessonParameters.rigidBodyPosition.x, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.rigidBodyPosition.x))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Position Y:")
                                                    Slider(value: $lessonParameters.rigidBodyPosition.y, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.rigidBodyPosition.y))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Position Z:")
                                                    Slider(value: $lessonParameters.rigidBodyPosition.z, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.rigidBodyPosition.z))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Rotation:")
                                                    Slider(value: $lessonParameters.rigidBodyRotation, in: 0...Double.pi*2)
                                                    Text(String(format: "%.1f°", lessonParameters.rigidBodyRotation * 180 / Double.pi))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                            case .collisionDetection:
                                                HStack {
                                                    Text("Object 1 X:")
                                                    Slider(value: $lessonParameters.collision1Position.x, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.collision1Position.x))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Object 1 Y:")
                                                    Slider(value: $lessonParameters.collision1Position.y, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.collision1Position.y))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Object 1 Z:")
                                                    Slider(value: $lessonParameters.collision1Position.z, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.collision1Position.z))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Object 1 Radius:")
                                                    Slider(value: $lessonParameters.collision1Radius, in: 0.1...3)
                                                    Text(String(format: "%.1f", lessonParameters.collision1Radius))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Object 2 X:")
                                                    Slider(value: $lessonParameters.collision2Position.x, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.collision2Position.x))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Object 2 Y:")
                                                    Slider(value: $lessonParameters.collision2Position.y, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.collision2Position.y))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Object 2 Z:")
                                                    Slider(value: $lessonParameters.collision2Position.z, in: -5...5)
                                                    Text(String(format: "%.1f", lessonParameters.collision2Position.z))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                                
                                                HStack {
                                                    Text("Object 2 Radius:")
                                                    Slider(value: $lessonParameters.collision2Radius, in: 0.1...3)
                                                    Text(String(format: "%.1f", lessonParameters.collision2Radius))
                                                        .frame(width: 40, alignment: .trailing)
                                                        .monospacedDigit()
                                                }
                                            }
                                            .onChange(of: lessonParameters.applicationType) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.cameraPosition) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.lookAtPoint) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.rigidBodyType) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.rigidBodyPosition) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.rigidBodyRotation) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.collision1Position) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.collision1Radius) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.collision2Position) { _ in updateVisualization() }
                                            .onChange(of: lessonParameters.collision2Radius) { _ in updateVisualization() }
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Step by Step Explanation
                            
                            /// Step-by-step explanation panel
                            private var stepByStepExplanation: some View {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Step-by-Step Explanation")
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Button(action: {
                                                if currentStep > 0 {
                                                    currentStep -= 1
                                                    updateVisualizationForStep(currentStep)
                                                }
                                            }) {
                                                Image(systemName: "chevron.left")
                                            }
                                            .disabled(currentStep <= 0)
                                            
                                            Text("\(currentStep + 1) / \(currentLesson.steps.count)")
                                                .frame(width: 60, alignment: .center)
                                            
                                            Button(action: {
                                                if currentStep < currentLesson.steps.count - 1 {
                                                    currentStep += 1
                                                    updateVisualizationForStep(currentStep)
                                                }
                                            }) {
                                                Image(systemName: "chevron.right")
                                            }
                                            .disabled(currentStep >= currentLesson.steps.count - 1)
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    if currentLesson.steps.count > currentStep {
                                        let step = currentLesson.steps[currentStep]
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            if step.isHeader {
                                                Text(step.latex)
                                                    .font(.headline)
                                            } else {
                                                LaTeXView(step.latex, fontSize: 16, inline: false)
                                                    .padding(.vertical, 4)
                                            }
                                            
                                            if let explanation = step.explanation {
                                                Text(explanation)
                                                    .font(.body)
                                                    .foregroundColor(.secondary)
                                                    .padding(.top, 4)
                                            }
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding()
                            }
                            
                            // MARK: - Visualization Methods
                            
                            /// Set up the initial visualization
                            private func setupVisualization() {
                                // Configure the visualizer
                                visualizer.showAxes(true)
                                
                                // Reset lesson parameters to defaults
                                resetLessonParameters()
                                
                                // Update the visualization for the current lesson
                                updateVisualization()
                            }
                            
                            /// Reset lesson parameters to default values
                            private func resetLessonParameters() {
                                // Reset parameters to default values for the current lesson
                                lessonParameters = LessonParameters()
                                
                                // Set current step to 0
                                currentStep = 0
                            }
                            
                            /// Update the visualization based on the current lesson and parameters
                            private func updateVisualization() {
                                // Clear the visualizer
                                visualizer.clearAll()
                                entityIDs.removeAll()
                                
                                // Update the visualization based on the current lesson
                                switch currentLesson {
                                case .introduction:
                                    visualizeIntroduction()
                                case .points:
                                    visualizePoints()
                                case .spheres:
                                    visualizeSpheres()
                                case .planes:
                                    visualizePlanes()
                                case .circles:
                                    visualizeCircles()
                                case .lines:
                                    visualizeLines()
                                case .pointPairs:
                                    visualizePointPairs()
                                case .intersections:
                                    visualizeIntersections()
                                case .transformations:
                                    visualizeTransformations()
                                case .applications:
                                    visualizeApplications()
                                }
                            }
                            
                            /// Update the visualization for a specific step
                            private func updateVisualizationForStep(_ step: Int) {
                                // Update visualization based on step
                                // This would show different aspects of the visualization
                                // depending on the current step in the explanation
                                
                                // For now, we'll just update the regular visualization
                                updateVisualization()
                            }
                            
                            // MARK: - Lesson-Specific Visualizations
                            
                            /// Visualize the introduction lesson
                            private func visualizeIntroduction() {
                                // Show the basis vectors of conformal space
                                
                                // Regular 3D basis vectors
                                let e1ID = visualizer.addVector(
                                    from: SIMD3<Double>.zero,
                                    to: SIMD3<Double>(1, 0, 0),
                                    color: NSColor.red,
                                    name: "e₁"
                                )
                                entityIDs["e1"] = e1ID
                                
                                let e2ID = visualizer.addVector(
                                    from: SIMD3<Double>.zero,
                                    to: SIMD3<Double>(0, 1, 0),
                                    color: NSColor.green,
                                    name: "e₂"
                                )
                                entityIDs["e2"] = e2ID
                                
                                let e3ID = visualizer.addVector(
                                    from: SIMD3<Double>.zero,
                                    to: SIMD3<Double>(0, 0, 1),
                                    color: NSColor.blue,
                                    name: "e₃"
                                )
                                entityIDs["e3"] = e3ID
                                
                                // Add a point at the origin
                                let originID = visualizer.addPoint(
                                    position: SIMD3<Double>.zero,
                                    color: NSColor.yellow,
                                    size: 0.1,
                                    name: "Origin"
                                )
                                entityIDs["origin"] = originID
                                
                                // Add a sphere representing "infinity"
                                let infinityID = visualizer.addSphere(
                                    center: SIMD3<Double>.zero,
                                    radius: 5.0,
                                    color: NSColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 0.2),
                                    opacity: 0.2,
                                    name: "e∞"
                                )
                                entityIDs["infinity"] = infinityID
                            }
                            
                            /// Visualize the points lesson
                            private func visualizePoints() {
                                // Add the Euclidean point
                                let pointID = visualizer.addPoint(
                                    position: lessonParameters.point,
                                    color: NSColor.yellow,
                                    size: 0.15,
                                    name: "p"
                                )
                                entityIDs["point"] = pointID
                                
                                // Add a vector from origin to the point
                                let vectorID = visualizer.addVector(
                                    from: SIMD3<Double>.zero,
                                    to: lessonParameters.point,
                                    color: NSColor.white,
                                    thickness: 0.03,
                                    name: "vec(p)"
                                )
                                entityIDs["vector"] = vectorID
                                
                                // Add the CGA point representation (as a smaller point)
                                let cgaPointID = visualizer.addPoint(
                                    position: lessonParameters.point,
                                    color: NSColor.cyan,
                                    size: 0.1,
                                    name: "P"
                                )
                                entityIDs["cgaPoint"] = cgaPointID
                            }
                            
                            /// Visualize the spheres lesson
                            private func visualizeSpheres() {
                                // Add the center point
                                let centerID = visualizer.addPoint(
                                    position: lessonParameters.sphereCenter,
                                    color: NSColor.yellow,
                                    size: 0.1,
                                    name: "center"
                                )
                                entityIDs["center"] = centerID
                                
                                // Add the sphere
                                let sphereID = visualizer.addSphere(
                                    center: lessonParameters.sphereCenter,
                                    radius: lessonParameters.sphereRadius,
                                    color: NSColor.cyan,
                                    opacity: 0.3,
                                    name: "Sphere"
                                )
                                entityIDs["sphere"] = sphereID
                                
                                // Add a vector from origin to center
                                let vectorID = visualizer.addVector(
                                    from: SIMD3<Double>.zero,
                                    to: lessonParameters.sphereCenter,
                                    color: NSColor.white,
                                    thickness: 0.02,
                                    name: "vec(c)"
                                )
                                entityIDs["vector"] = vectorID
                                
                                // Add a point on the sphere surface
                                let surfacePoint = lessonParameters.sphereCenter +
                                                  SIMD3<Double>(lessonParameters.sphereRadius, 0, 0)
                                let surfaceID = visualizer.addPoint(
                                    position: surfacePoint,
                                    color: NSColor.orange,
                                    size: 0.08,
                                    name: "Surface Point"
                                )
                                entityIDs["surface"] = surfaceID
                            }
                            
                            /// Visualize the planes lesson
                            private func visualizePlanes() {
                                // Normalize normal vector
                                let normal = simd_normalize(lessonParameters.planeNormal)
                                
                                // Add the normal vector
                                let normalID = visualizer.addVector(
                                    from: SIMD3<Double>.zero,
                                    to: normal * 2.0,
                                    color: NSColor.yellow,
                                    thickness: 0.05,
                                    name: "n"
                                )
                                entityIDs["normal"] = normalID
                                
                                // Add the plane
                                let planeID = visualizer.addPlane(
                                    normal: normal,
                                    distance: lessonParameters.planeDistance,
                                    size: 10.0,
                                    color: NSColor.cyan,
                                    opacity: 0.3,
                                    name: "Plane"
                                )
                                entityIDs["plane"] = planeID
                                
                                // Calculate a point on the plane
                                let planePoint = normal * lessonParameters.planeDistance
                                let pointID = visualizer.addPoint(
                                    position: planePoint,
                                    color: NSColor.orange,
                                    size: 0.1,
                                    name: "Point on Plane"
                                )
                                entityIDs["planePoint"] = pointID
                            }
                            
                            /// Visualize the circles lesson
                            private func visualizeCircles() {
                                // Add the center point
                                let centerID = visualizer.addPoint(
                                    position: lessonParameters.circleCenter,
                                    color: NSColor.yellow,
                                    size: 0.1,
                                    name: "center"
                                )
                                entityIDs["center"] = centerID
                                
                                // Normalize the normal vector
                                let normal = simd_normalize(lessonParameters.circleNormal)
                                
                                // Add the normal vector
                                let normalID = visualizer.addVector(
                                    from: lessonParameters.circleCenter,
                                    to: lessonParameters.circleCenter + normal * 1.5,
                                    color: NSColor.green,
                                    thickness: 0.03,
                                    name: "normal"
                                )
                                entityIDs["normal"] = normalID
                                
                                // Add the circle
                                let circleID = visualizer.addCircle(
                                    center: lessonParameters.circleCenter,
                                    radius: lessonParameters.circleRadius,
                                    normal: normal,
                                    color: NSColor.cyan,
                                    thickness: 0.04,
                                    name: "Circle"
                                )
                                entityIDs["circle"] = circleID
                                
                                // Add the plane that the circle lies on
                                let planeID = visualizer.addPlane(
                                    normal: normal,
                                    distance: -simd_dot(normal, lessonParameters.circleCenter),
                                    size: 5.0,
                                    color: NSColor.blue,
                                    opacity: 0.15,
                                    name: "Plane"
                                )
                                entityIDs["plane"] = planeID
                                
                                // Add a sphere that the circle lies on
                                let sphereID = visualizer.addSphere(
                                    center: lessonParameters.circleCenter,
                                    radius: lessonParameters.circleRadius,
                                    color: NSColor.purple,
                                    opacity: 0.15,
                                    name: "Sphere"
                                )
                                entityIDs["sphere"] = sphereID
                            }
                            
                            /// Visualize the lines lesson
                            private func visualizeLines() {
                                // Add the points
                                let point1ID = visualizer.addPoint(
                                    position: lessonParameters.linePoint1,
                                    color: NSColor.yellow,
                                    size: 0.1,
                                    name: "P₁"
                                )
                                entityIDs["point1"] = point1ID
                                
                                let point2ID = visualizer.addPoint(
                                    position: lessonParameters.linePoint2,
                                    color: NSColor.yellow,
                                    size: 0.1,
                                    name: "P₂"
                                )
                                entityIDs["point2"] = point2ID
                                
                                // Add the line
                                let lineID = visualizer.addLine(
                                    from: lessonParameters.linePoint1,
                                    to: lessonParameters.linePoint2,
                                    color: NSColor.cyan,
                                    thickness: 0.05,
                                    name: "Line"
                                )
                                entityIDs["line"] = lineID
                                
                                // Calculate direction and moment
                                let direction = simd_normalize(lessonParameters.linePoint2 - lessonParameters.linePoint1)
                                let center = (lessonParameters.linePoint1 + lessonParameters.linePoint2) * 0.5
                                
                                // Add direction vector
                                let directionID = visualizer.addVector(
                                    from: center,
                                    to: center + direction * 1.5,
                                    color: NSColor.green,
                                    thickness: 0.03,
                                    name: "dir"
                                )
                                entityIDs["direction"] = directionID
                            }
                            
                            /// Visualize the point pairs lesson
                            private func visualizePointPairs() {
                                // Add the points
                                let point1ID = visualizer.addPoint(
                                    position: lessonParameters.pairPoint1,
                                    color: NSColor.yellow,
                                    size: 0.1,
                                    name: "P₁"
                                )
                                entityIDs["point1"] = point1ID
                                
                                let point2ID = visualizer.addPoint(
                                    position: lessonParameters.pairPoint2,
                                    color: NSColor.yellow,
                                    size: 0.1,
                                    name: "P₂"
                                )
                                entityIDs["point2"] = point2ID
                                
                                // Add a line connecting the points
                                let lineID = visualizer.addLine(
                                    from: lessonParameters.pairPoint1,
                                    to: lessonParameters.pairPoint2,
                                    color: NSColor.green,
                                    thickness: 0.03,
                                    name: "Line"
                                )
                                entityIDs["line"] = lineID
                                
                                // Calculate the center and direction
                                let center = (lessonParameters.pairPoint1 + lessonParameters.pairPoint2) * 0.5
                                let direction = simd_normalize(lessonParameters.pairPoint2 - lessonParameters.pairPoint1)
                                let distance = simd_distance(lessonParameters.pairPoint1, lessonParameters.pairPoint2)
                                
                                // Add center point
                                let centerID = visualizer.addPoint(
                                    position: center,
                                    color: NSColor.cyan,
                                    size: 0.08,
                                    name: "Center"
                                )
                                entityIDs["center"] = centerID
                                
                                // Add a sphere with center at midpoint and radius as half the distance
                                let sphereID = visualizer.addSphere(
                                    center: center,
                                    radius: distance * 0.5,
                                    color: NSColor.purple,
                                    opacity: 0.15,
                                    name: "Sphere"
                                )
                                entityIDs["sphere"] = sphereID
                            }
                            
                            /// Visualize the intersections lesson
                            private func visualizeIntersections() {
                                switch lessonParameters.intersectionType {
                                case .spherePlane:
                                    // Add the sphere
                                    let sphereID = visualizer.addSphere(
                                        center: lessonParameters.sphereCenter,
                                        radius: lessonParameters.sphereRadius,
                                        color: NSColor.purple,
                                        opacity: 0.3,
                                        name: "Sphere"
                                    )
                                    entityIDs["sphere"] = sphereID
                                    
                                    // Add the plane
                                    let normal = simd_normalize(lessonParameters.planeNormal)
                                    let planeID = visualizer.addPlane(
                                        normal: normal,
                                        distance: lessonParameters.planeDistance,
                                        size: 5.0,
                                        color: NSColor.blue,
                                        opacity: 0.3,
                                        name: "Plane"
                                    )
                                    entityIDs["plane"] = planeID
                                    
                                    // Calculate the intersection circle
                                    let spherePoint = lessonParameters.sphereCenter
                                    let planePoint = normal * lessonParameters.planeDistance
                                    
                                    // Distance from sphere center to plane
                                    let distToPlane = simd_dot(normal, spherePoint - planePoint)
                                    
                                    // If sphere intersects plane, draw the circle of intersection
                                    if abs(distToPlane) < lessonParameters.sphereRadius {
                                        // Circle center is the projection of sphere center onto plane
                                        let circleCenter = spherePoint - normal * distToPlane
                                        
                                        // Circle radius depends on distance from sphere center to plane
                                        let circleRadius = sqrt(lessonParameters.sphereRadius * lessonParameters.sphereRadius - distToPlane * distToPlane)
                                        
                                        // Add the intersection circle
                                        let circleID = visualizer.addCircle(
                                            center: circleCenter,
                                            radius: circleRadius,
                                            normal: normal,
                                            color: NSColor.red,
                                            thickness: 0.05,
                                            name: "Intersection"
                                        )
                                        entityIDs["intersection"] = circleID
                                    }
                                    
                                case .sphereSphere:
                                    // Add the first sphere
                                    let sphere1ID = visualizer.addSphere(
                                        center: lessonParameters.sphere1Center,
                                        radius: lessonParameters.sphere1Radius,
                                        color: NSColor.purple,
                                        opacity: 0.3,
                                        name: "Sphere 1"
                                    )
                                    entityIDs["sphere1"] = sphere1ID
                                    
                                    // Add the second sphere
                                    let sphere2ID = visualizer.addSphere(
                                        center: lessonParameters.sphere2Center,
                                        radius: lessonParameters.sphere2Radius,
                                        color: NSColor.blue,
                                        opacity: 0.3,
                                        name: "Sphere 2"
                                    )
                                    entityIDs["sphere2"] = sphere2ID
                                    
                                    // Calculate the intersection circle
                                    let center1 = lessonParameters.sphere1Center
                                    let center2 = lessonParameters.sphere2Center
                                    let r1 = lessonParameters.sphere1Radius
                                    let r2 = lessonParameters.sphere2Radius
                                    
                                    // Vector from center1 to center2
                                    let v = center2 - center1
                                    let d = simd_length(v)
                                    
                                    // If spheres intersect, draw the circle of intersection
                                    if d < r1 + r2 && d > abs(r1 - r2) {
                                        // Normalized direction vector
                                        let direction = v / d
                                        
                                        // Distance from center1 to the plane of intersection
                                        let a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
                                        
                                        // Circle center
                                        let circleCenter = center1 + direction * a
                                        
                                        // Circle radius
                                        let circleRadius = sqrt(r1 * r1 - a * a)
                                        
                                        // Add the intersection circle
                                        let circleID = visualizer.addCircle(
                                            center: circleCenter,
                                            radius: circleRadius,
                                            normal: direction,
                                            color: NSColor.red,
    
