import 'dart:async';
import 'package:flutter/material.dart';

const Color kGreen = Color(0xFF16866A);
const Color kBackground = Color(0xFFF4F7F5);
const Color kMuted = Color(0xFF84918B);

void main() {
  runApp(const TasklyApp());
}

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
      ),
      home: const TasklyHome(),
    );
  }
}

class TaskItem {
  TaskItem({
    required this.title,
    required this.subject,
    required this.deadline,
    this.completed = false,
  });

  String title;
  String subject;
  DateTime deadline;
  bool completed;
}

class Lecture {
  final String day;
  final String time;
  final String subject;
  final String type;
  final String room;

  const Lecture(
    this.day,
    this.time,
    this.subject,
    this.type,
    this.room,
  );
}

const List<String> weekDays = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
];

const List<Lecture> classSchedules = [
  Lecture('Senin', '07.30–11.30', 'Analisis & Perancangan SI', 'Praktik', 'Lab Software 1'),
  Lecture('Senin', '17.00–21.00', 'Pemrograman Aplikasi Mobile 1', 'Praktik', 'Lab Software 1'),
  Lecture('Selasa', '13.00–15.50', 'Percakapan Bahasa Inggris', 'Teori & Praktik', 'SFS 2.4'),
  Lecture('Selasa', '16.00–18.00', 'Pemrograman API', 'Praktik', 'SFS 3.3'),
  Lecture('Rabu', '07.00–11.00', 'PW III', 'Praktik', 'Lab Software 2'),
  Lecture('Rabu', '13.00–17.00', 'Perancangan UI/UX', 'Praktik', 'Lab Software 2'),
  Lecture('Rabu', '18.00–18.50', 'Sistem Basis Data', 'Teori', 'Daring'),
  Lecture('Rabu', '18.50–19.40', 'K3', 'Teori', 'Daring'),
  Lecture('Rabu', '19.40–20.30', 'Analisis & Perancangan SI', 'Teori', 'Daring'),
  Lecture('Kamis', '15.00–17.00', 'K3', 'Praktik', 'SFS 2.4'),
  Lecture('Kamis', '18.00–18.50', 'Perancangan UI/UX', 'Teori', 'Daring'),
  Lecture('Kamis', '18.50–19.40', 'Pemrograman API', 'Teori', 'Daring'),
  Lecture('Kamis', '19.40–20.30', 'Visualisasi Data', 'Teori', 'Daring'),
  Lecture('Jumat', '09.00–11.00', 'Sistem Basis Data', 'Praktik', 'Lab Software 1'),
  Lecture('Jumat', '13.30–15.30', 'Visualisasi Data', 'Praktik', 'SFS 3.2'),
  Lecture('Jumat', '18.30–19.20', 'Pemrograman Aplikasi Mobile 1', 'Teori', 'Daring'),
  Lecture('Jumat', '19.20–20.10', 'PW III', 'Teori', 'Daring'),
];

class TasklyHome extends StatefulWidget {
  const TasklyHome({super.key});

  @override
  State<TasklyHome> createState() => _TasklyHomeState();
}

class _TasklyHomeState extends State<TasklyHome> {
  int selectedPage = 0;
  int selectedDay = 0;
  String searchQuery = '';

  final List<TaskItem> tasks = [];
  final TextEditingController searchController = TextEditingController();

  final List<String> pageNames = [
    'Dashboard',
    'Semua Tugas',
    'Jadwal Kuliah',
    'Fokus',
  ];

  final List<IconData> pageIcons = [
    Icons.dashboard_outlined,
    Icons.checklist_outlined,
    Icons.calendar_month_outlined,
    Icons.timer_outlined,
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<TaskItem> get filteredTasks {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(query) ||
          task.subject.toLowerCase().contains(query);
    }).toList();
  }

  void changePage(int index) {
    setState(() => selectedPage = index);
  }

  Future<void> addTask() async {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    DateTime deadline = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Tugas'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Nama tugas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Mata kuliah',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: deadline,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() => deadline = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      setState(() {
        tasks.add(
          TaskItem(
            title: titleController.text.trim(),
            subject: subjectController.text.trim().isEmpty
                ? 'Umum'
                : subjectController.text.trim(),
            deadline: deadline,
          ),
        );
      });
    }

    titleController.dispose();
    subjectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  title: const Text(
                    'Taskly',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  leading: Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Buka menu',
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Tambah tugas',
                      icon: const Icon(Icons.add),
                      onPressed: addTask,
                    ),
                  ],
                )
              : null,
          drawer: isMobile
              ? Drawer(
                  child: SafeArea(child: buildSidebar(inDrawer: true)),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                SizedBox(width: 245, child: buildSidebar()),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile) buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : 28),
                        child: buildSelectedPage(isMobile),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSidebar({bool inDrawer = false}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Taskly',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Text(
            'MENU UTAMA',
            style: TextStyle(
              color: kMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(pageNames.length, (index) {
            final active = selectedPage == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                selected: active,
                selectedTileColor: const Color(0xFFE5F3EC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  pageIcons[index],
                  color: active ? kGreen : kMuted,
                ),
                title: Text(
                  pageNames[index],
                  style: TextStyle(
                    color: active ? kGreen : Colors.black87,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  changePage(index);
                  if (inDrawer) Navigator.pop(context);
                },
              ),
            );
          }),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: kGreen, size: 28),
                SizedBox(height: 8),
                Text(
                  'Tetap produktif!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Selesaikan satu tugas pada satu waktu.',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  if (value.trim().isNotEmpty) selectedPage = 1;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari tugas atau mata kuliah...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: addTask,
            icon: const Icon(Icons.add),
            label: const Text('Tugas Baru'),
            style: FilledButton.styleFrom(
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(17),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectedPage(bool isMobile) {
    switch (selectedPage) {
      case 1:
        return buildTasksPage();
      case 2:
        return buildSchedulePage();
      case 3:
        return const FocusPage();
      default:
        return buildDashboard();
    }
  }

  Widget buildDashboard() {
    final completed = tasks.where((task) => task.completed).length;
    final pending = tasks.length - completed;
    final today = DateTime.now().weekday;
    final todayName =
        today >= 1 && today <= 5 ? weekDays[today - 1] : '';

    final todayLectures =
        classSchedules.where((lecture) => lecture.day == todayName).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF176F5A), Color(0xFF29A581)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateTime.now().day} ${monthName(DateTime.now().month)} ${DateTime.now().year}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              const Text(
                'Halo, selamat datang! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pending == 0
                    ? 'Tidak ada tugas tertunda. Tetap semangat!'
                    : 'Kamu memiliki $pending tugas yang belum selesai.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: addTask,
                icon: const Icon(Icons.add),
                label: const Text('Buat Tugas'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 500 ? 1 : 3;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 3.2 : 1.35,
              children: [
                statCard('Total Tugas', tasks.length, Icons.assignment_outlined),
                statCard('Belum Selesai', pending, Icons.pending_actions),
                statCard('Selesai', completed, Icons.task_alt),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // GRAFIK DONAT DAN GRAFIK BATANG
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 680;
            final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

            final subjectCounts = <String, int>{};
            for (final task in tasks) {
              subjectCounts[task.subject] =
                  (subjectCounts[task.subject] ?? 0) + 1;
            }

            final sortedSubjects = subjectCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final chartSubjects = sortedSubjects.take(5).toList();

            final progressCard = Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7ECE9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Progres Penyelesaian'),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 170,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            painter: DonutChartPainter(
                              completed: completed,
                              pending: pending,
                              green: kGreen,
                              pendingColor: const Color(0xFFFFC779),
                              trackColor: const Color(0xFFEAF0EC),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Selesai',
                                    style: TextStyle(
                                      color: kMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              chartLegend(kGreen, 'Selesai', completed),
                              const SizedBox(height: 14),
                              chartLegend(
                                const Color(0xFFFFC779),
                                'Belum selesai',
                                pending,
                              ),
                              const SizedBox(height: 14),
                              chartLegend(
                                const Color(0xFFEAF0EC),
                                'Total tugas',
                                tasks.length,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final subjectCard = Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7ECE9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Tugas per Mata Kuliah'),
                  const SizedBox(height: 8),
                  const Text(
                    'Maksimal 5 mata kuliah dengan tugas terbanyak',
                    style: TextStyle(color: kMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  if (chartSubjects.isEmpty)
                    const SizedBox(
                      height: 150,
                      child: Center(
                        child: Text(
                          'Grafik akan muncul setelah kamu menambahkan tugas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kMuted),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 180,
                      child: CustomPaint(
                        painter: SubjectBarChartPainter(
                          entries: chartSubjects,
                          barColor: kGreen,
                          labelColor: kMuted,
                          gridColor: const Color(0xFFE9EFEB),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ),
            );

            if (isNarrow) {
              return Column(
                children: [
                  progressCard,
                  const SizedBox(height: 14),
                  subjectCard,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: progressCard),
                const SizedBox(width: 14),
                Expanded(child: subjectCard),
              ],
            );
          },
        ),

        const SizedBox(height: 24),
        sectionTitle('Tugas Terbaru'),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          emptyMessage('Belum ada tugas. Tambahkan tugas pertamamu.')
        else
          ...tasks.reversed.take(5).map(taskCard),
        const SizedBox(height: 24),
        sectionTitle('Jadwal Kuliah Hari Ini'),
        const SizedBox(height: 12),
        if (todayLectures.isEmpty)
          emptyMessage('Tidak ada jadwal kuliah hari ini.')
        else
          ...todayLectures.map(lectureCard),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => setState(() => selectedPage = 2),
          child: const Text('Lihat Semua Jadwal'),
        ),
      ],
    );
  }

  Widget statCard(String title, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECE9)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kGreen, size: 26),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildTasksPage() {
    final visibleTasks = filteredTasks;
    final pending = visibleTasks.where((task) => !task.completed).toList();
    final completed = visibleTasks.where((task) => task.completed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semua Tugas',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kelola semua tugas, mata kuliah, dan deadline.',
          style: TextStyle(color: kMuted),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: addTask,
          icon: const Icon(Icons.add),
          label: const Text('Tambah Tugas'),
        ),
        const SizedBox(height: 24),
        sectionTitle('Belum Selesai (${pending.length})'),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          emptyMessage('Tidak ada tugas yang belum selesai.')
        else
          ...pending.map(taskCard),
        const SizedBox(height: 24),
        sectionTitle('Selesai (${completed.length})'),
        const SizedBox(height: 10),
        if (completed.isEmpty)
          emptyMessage('Belum ada tugas yang selesai.')
        else
          ...completed.map(taskCard),
      ],
    );
  }

  Widget taskCard(TaskItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE4EAE6)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.completed,
            activeColor: kGreen,
            onChanged: (value) {
              setState(() => task.completed = value ?? false);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.subject} • Deadline ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                  style: const TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hapus tugas',
            onPressed: () {
              setState(() => tasks.remove(task));
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSchedulePage() {
    final day = weekDays[selectedDay];
    final dayLectures =
        classSchedules.where((lecture) => lecture.day == day).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Kuliah',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'MI-3C · Semester Ganjil',
          style: TextStyle(color: kMuted, fontSize: 15),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(weekDays.length, (index) {
            return ChoiceChip(
              label: Text(weekDays[index]),
              selected: selectedDay == index,
              selectedColor: const Color(0xFFD4EDE1),
              onSelected: (selected) {
                if (selected) setState(() => selectedDay = index);
              },
            );
          }),
        ),
        const SizedBox(height: 24),
        Text(
          day.toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(height: 24),
        if (dayLectures.isEmpty)
          emptyMessage('Tidak ada jadwal untuk hari ini.')
        else
          ...dayLectures.map(lectureCard),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: selectedDay > 0
                  ? () => setState(() => selectedDay--)
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Sebelumnya'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: selectedDay < weekDays.length - 1
                  ? () => setState(() => selectedDay++)
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Berikutnya'),
            ),
          ],
        ),
      ],
    );
  }

  Widget lectureCard(Lecture lecture) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8E3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 72,
            decoration: BoxDecoration(
              color: kGreen,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.time,
                  style: const TextStyle(
                    color: kGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  lecture.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${lecture.type} · ${lecture.room}',
                  style: const TextStyle(color: kMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget chartLegend(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: kMuted),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
    );
  }

  Widget emptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: kMuted),
      ),
    );
  }
}

// GRAFIK DONAT
class DonutChartPainter extends CustomPainter {
  final int completed;
  final int pending;
  final Color green;
  final Color pendingColor;
  final Color trackColor;

  DonutChartPainter({
    required this.completed,
    required this.pending,
    required this.green,
    required this.pendingColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width < size.height ? size.width : size.height;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side * 0.78,
      height: side * 0.78,
    );

    const stroke = 18.0;

    final backgroundPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(
      rect,
      0,
      3.141592653589793 * 2,
      false,
      backgroundPaint,
    );

    final total = completed + pending;
    if (total == 0) return;

    final completedPaint = Paint()
      ..color = green
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final pendingPaint = Paint()
      ..color = pendingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    const start = -1.5707963267948966;
    final completedSweep = 6.283185307179586 * completed / total;
    final pendingSweep = 6.283185307179586 * pending / total;

    if (completed > 0) {
      canvas.drawArc(
        rect,
        start,
        completedSweep,
        false,
        completedPaint,
      );
    }

    if (pending > 0) {
      canvas.drawArc(
        rect,
        start + completedSweep,
        pendingSweep,
        false,
        pendingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return completed != oldDelegate.completed ||
        pending != oldDelegate.pending;
  }
}

// GRAFIK BATANG TUGAS PER MATA KULIAH
class SubjectBarChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final Color barColor;
  final Color labelColor;
  final Color gridColor;

  SubjectBarChartPainter({
    required this.entries,
    required this.barColor,
    required this.labelColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const left = 8.0;
    const right = 24.0;
    const top = 8.0;
    const bottom = 28.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final maxValue = entries
        .map((entry) => entry.value)
        .reduce((a, b) => a > b ? a : b);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final barPaint = Paint()..color = barColor;
    const labelPainterStyle = TextStyle(fontSize: 10, color: kMuted);

    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final slot = chartWidth / entries.length;

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];

      final barHeight =
          maxValue == 0 ? 0.0 : chartHeight * entry.value / maxValue;

      final barWidth = slot * 0.48;
      final x = left + slot * i + (slot - barWidth) / 2;
      final y = top + chartHeight - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(5),
        ),
        barPaint,
      );

      final countPainter = TextPainter(
        text: TextSpan(
          text: '${entry.value}',
          style: const TextStyle(
            fontSize: 11,
            color: kGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slot);

      countPainter.paint(
        canvas,
        Offset(
          x + (barWidth - countPainter.width) / 2,
          (y - 16).clamp(0.0, size.height).toDouble(),
        ),
      );

      final label = entry.key.length > 11
          ? '${entry.key.substring(0, 10)}…'
          : entry.key;

      final labelPainter = TextPainter(
        text: TextSpan(text: label, style: labelPainterStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: slot - 2);

      labelPainter.paint(
        canvas,
        Offset(
          left + slot * i + (slot - labelPainter.width) / 2,
          size.height - bottom + 7,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SubjectBarChartPainter oldDelegate) {
    return entries != oldDelegate.entries;
  }
}

String monthName(int month) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return months[month - 1];
}

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  Timer? timer;

  int focusMinutes = 25;
  int breakMinutes = 5;
  int longBreakMinutes = 15;

  int mode = 0;
  int remainingSeconds = 25 * 60;
  bool running = false;

  int get currentMinutes {
    if (mode == 0) return focusMinutes;
    if (mode == 1) return breakMinutes;
    return longBreakMinutes;
  }

  String get timeText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;

    if (mounted) {
      setState(() => running = false);
    }
  }

  void chooseMode(int newMode) {
    stopTimer();

    setState(() {
      mode = newMode;
      remainingSeconds = currentMinutes * 60;
    });
  }

  void startOrPause() {
    if (running) {
      stopTimer();
      return;
    }

    if (remainingSeconds <= 0) {
      setState(() => remainingSeconds = currentMinutes * 60);
    }

    setState(() => running = true);

    timer = Timer.periodic(const Duration(seconds: 1), (timerInstance) {
      if (!mounted) {
        timerInstance.cancel();
        return;
      }

      if (remainingSeconds <= 1) {
        timerInstance.cancel();

        setState(() {
          remainingSeconds = 0;
          running = false;
        });
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    timer = null;

    setState(() {
      running = false;
      remainingSeconds = currentMinutes * 60;
    });
  }

  void changeMinutes(int newMode, int value) {
    if (value < 1 || value > 180) return;

    setState(() {
      if (newMode == 0) focusMinutes = value;
      if (newMode == 1) breakMinutes = value;
      if (newMode == 2) longBreakMinutes = value;

      if (mode == newMode) {
        remainingSeconds = value * 60;
        running = false;
        timer?.cancel();
        timer = null;
      }
    });
  }

  Widget modeButton(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      selected: mode == value,
      selectedColor: const Color(0xFF80C49B),
      backgroundColor: const Color(0xFF303737),
      labelStyle: TextStyle(
        color: mode == value ? Colors.black : Colors.white,
      ),
      onSelected: (_) => chooseMode(value),
    );
  }

  Widget minuteInput(
    String label,
    int value,
    int modeIndex,
  ) {
    return SizedBox(
      width: 145,
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
            items: List.generate(12, (index) {
              final minutes = (index + 1) * 5;

              return DropdownMenuItem<int>(
                value: minutes,
                child: Text('$minutes menit'),
              );
            }),
            onChanged: (newValue) {
              if (newValue != null) {
                changeMinutes(modeIndex, newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fokus',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Atur waktu belajar dan istirahat dengan metode Pomodoro.',
          style: TextStyle(color: kMuted),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 30,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2020),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  modeButton('Fokus', 0),
                  modeButton('Istirahat', 1),
                  modeButton('Istirahat Panjang', 2),
                ],
              ),
              const SizedBox(height: 30),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  timeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 82,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: startOrPause,
                    icon: Icon(
                      running ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(running ? 'Jeda' : 'Mulai'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF80C49B),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 15,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: resetTimer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (remainingSeconds == 0) ...[
                const SizedBox(height: 18),
                const Text(
                  'Waktu selesai!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Pengaturan Waktu',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            minuteInput('Waktu Fokus', focusMinutes, 0),
            minuteInput('Istirahat', breakMinutes, 1),
            minuteInput('Istirahat Panjang', longBreakMinutes, 2),
          ],
        ),
      ],
    );
  }
}