import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class Lab {
  final String name;
  final String address;
  final String state;

  Lab({required this.name, required this.address, required this.state});
}

class LabsScreen extends StatefulWidget {
  const LabsScreen({super.key});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  List<Lab> _allLabs = [];
  List<Lab> _filteredLabs = [];
  bool _isLoading = true;

  String? _selectedState;
  List<String> _availableStates = [];
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  Future<void> _loadCsvData() async {
    try {
      final String rawData = await rootBundle.loadString('assests/data/biocontrol_labs.csv');
      List<List<String>> listData = _parseCsv(rawData);
      
      // Remove header row if present
      if (listData.isNotEmpty && listData[0].contains("Name")) {
        listData.removeAt(0);
      }

      List<Lab> parsedLabs = [];
      Set<String> foundStates = {};

      for (var row in listData) {
        String name = row.length > 1 ? row[1] : "";
        String address = row.length > 2 ? row[2] : "";
        
        if (name.isEmpty && address.isEmpty) continue;
        if (name == "Name" && address == "Address") continue; // Extra safety check

        String state = _getStateFromAddress(address);
        if (state != "Other") {
          foundStates.add(state);
        }
        
        parsedLabs.add(Lab(name: name, address: address, state: state));
      }

      // Sort states alphabetically
      List<String> statesList = foundStates.toList()..sort();

      setState(() {
        _allLabs = parsedLabs;
        _availableStates = statesList;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      debugPrint("Error loading CSV: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to extract state from address
  String _getStateFromAddress(String address) {
    const states = [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 
      'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 
      'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 
      'Uttarakhand', 'West Bengal', 'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Puducherry'
    ];
    
    String upperAddr = address.toUpperCase();
    for (var state in states) {
      if (upperAddr.contains(state.toUpperCase())) {
        return state;
      }
    }
    return 'Other';
  }

  void _applyFilters() {
    List<Lab> temp = List.from(_allLabs);

    // Filter by State
    if (_selectedState != null) {
      temp = temp.where((lab) => lab.state == _selectedState).toList();
    }

    // Sort by Name
    temp.sort((a, b) {
      return _sortAscending 
          ? a.name.compareTo(b.name) 
          : b.name.compareTo(a.name);
    });

    setState(() {
      _filteredLabs = temp;
    });
  }

  // Simple CSV parser that handles quoted fields
  List<List<String>> _parseCsv(String data) {
    List<List<String>> result = [];
    List<String> currentRow = [];
    StringBuffer currentField = StringBuffer();
    bool insideQuotes = false;
    
    // Normalize line endings
    final chars = data.runes.toList();
    
    for (int i = 0; i < chars.length; i++) {
      final char = String.fromCharCode(chars[i]);
      
      if (insideQuotes) {
        if (char == '"') {
          // Check for escaped quote ("")
          if (i + 1 < chars.length && String.fromCharCode(chars[i + 1]) == '"') {
            currentField.write('"');
            i++; // Skip next quote
          } else {
            insideQuotes = false;
          }
        } else {
          currentField.write(char);
        }
      } else {
        if (char == '"') {
          insideQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentField.toString().trim());
          currentField.clear();
        } else if (char == '\n' || char == '\r') {
           // Handle end of line
           currentRow.add(currentField.toString().trim());
           currentField.clear();
           if (currentRow.any((field) => field.isNotEmpty)) {
             result.add(List.from(currentRow));
           }
           currentRow.clear();
           
           // Skip if next char is also newline char (e.g. \r\n)
           if (char == '\r' && i + 1 < chars.length && String.fromCharCode(chars[i + 1]) == '\n') {
             i++;
           }
        } else {
          currentField.write(char);
        }
      }
    }
    
    // Add last row if not empty
    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString().trim());
      if (currentRow.any((field) => field.isNotEmpty)) {
        result.add(currentRow);
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        AppLocalizations.of(context)!.biocontrolLabs,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.findLabsSubtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2D6A4F),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),

                // Filter & Sort Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // State Filter Dropdown
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    hint: Text(AppLocalizations.of(context)!.selectState, style: GoogleFonts.poppins(fontSize: 14)),
                                    value: _selectedState,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2D6A4F)),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(AppLocalizations.of(context)!.allStates, style: GoogleFonts.poppins(fontSize: 14)),
                                      ),
                                      ..._availableStates.map((state) {
                                        return DropdownMenuItem<String>(
                                          value: state,
                                          child: Text(state, style: GoogleFonts.poppins(fontSize: 14)),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedState = value;
                                        _applyFilters();
                                      });
                                    },
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Sort Button
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _sortAscending = !_sortAscending;
                                  _applyFilters();
                                });
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Icon(
                                  _sortAscending ? Icons.sort_by_alpha_rounded : Icons.sort_rounded,
                                  color: const Color(0xFF2D6A4F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedState != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.showingLabsIn,
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                                ),
                                Text(
                                  _selectedState!,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2D6A4F)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(top: 10)),

                _filteredLabs.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text(AppLocalizations.of(context)!.noLabsFound, style: GoogleFonts.poppins(color: Colors.grey)),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final lab = _filteredLabs[index];
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2D6A4F).withOpacity(0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (lab.name.isNotEmpty)
                                        Text(
                                          lab.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1B4332),
                                          ),
                                        ),
                                      if (lab.name.isNotEmpty && lab.address.isNotEmpty)
                                        const SizedBox(height: 8),
                                      if (lab.address.isNotEmpty)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: Color(0xFF52B788),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                lab.address,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: _filteredLabs.length,
                          ),
                        ),
                      ),
                // Add padding at bottom for navigation bar
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
    );
  }
}
