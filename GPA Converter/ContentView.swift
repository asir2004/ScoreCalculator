//
//  ContentView.swift
//  GPA Converter
//
//  Created by Asir Bygud on 2023-06-29.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var name = ""
    @State private var score : Int16 = 60
    @State private var point : Int16 = 3
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var courses: FetchedResults<Course>
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter Course Name", text: $name)
                    HStack {
                        Text("60")
                        Slider(value: Binding<Double>(
                            get: { Double(score) },
                            set: { newValue in score = Int16(newValue) }
                        ), in: 60...100, step: 5)
                        Text("100")
                    }
                    Stepper("Score: \(score)", value: $score)
                    Stepper("Point: \(point)", value: $point, in: 1...10)
                    Button("Save", action: SaveCourse)
                }
                
                Section(courses.count == 0 ? "Input your score and point..." : "Result") {
                    Button("Clear Courses") {
                        clearEntity(entityName: "Course")
                    }
                    .disabled(courses.count == 0)
                    
                    HStack {
                        Text(courses.count == 0 ? "Total score will be shown here →" : "Total Score")
                        Spacer()
                        if courses.count != 0 {
                            Text("\(calculateSum())")
                                .font(.headline)
                            Image(systemName: "divide")
                            Text("\(calculatePointSum())")
                                .foregroundColor(.secondary)
                            Image(systemName: "equal")
                            Text("\(calculateSum() / calculatePointSum())")
                                .font(.headline)
                        }
                    }
                    
                    if courses.count != 0 {
                        HStack {
                            Text("GPA")
                            Spacer()
                            Text("\(Double((Double(calculateSum()) / Double(calculatePointSum()) - 60) / 10), specifier: "%.2f")")
                        }
                    }
                }
                
                Section {
                    ForEach(courses, id: \.self) { course in
                        HStack {
                            Text(course.name ?? "Unknown Name")
                            Spacer()
                            Text("\(course.score)")
                                .font(.headline)
                            Text("\(course.point)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteCourse)
                    .animation(.default)
                }
            }
            .navigationTitle("GPA Converter")
            .toolbar {
                EditButton()
            }
        }
    }
    
    func calculateSum() -> Int {
        var sum = 0
        for course in courses {
            sum += Int(course.point) * Int(course.score)
        }
        return sum
    }
    
    func calculatePointSum() -> Int {
        var sum = 0
        for course in courses {
            sum += Int(course.point)
        }
        return sum
    }
    
    func SaveCourse() {
        let newCourse = Course(context: moc)
        newCourse.id = UUID()
        newCourse.name = name
        newCourse.score = score
        newCourse.point = point
        newCourse.date = Date()
        name = ""
        score = 60
        point = 3
        try? moc.save()
    }
    
    func deleteCourse(at offsets: IndexSet) {
        for offset in offsets {
            let course = courses[offset]
            moc.delete(course)
        }
        try? moc.save()
    }
    
    func clearEntity(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            let entities = try moc.fetch(fetchRequest) as? [NSManagedObject]
            for entity in entities ?? [] {
                moc.delete(entity)
            }
            try moc.save()
        } catch {
            print("Error clearing entity: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
