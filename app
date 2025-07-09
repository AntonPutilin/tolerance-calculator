# app.py

import streamlit as st
import re
import pandas as pd

def get_tolerance_data():
    """
    Stores the source data about tolerance fields from the table.
    """
    # Data from the ISO 286 (GOST 25346-89) standard
    return {
        # Grade 5
        "h5": [ (3, -4, 0), (6, -5, 0), (10, -6, 0), (18, -8, 0), (30, -9, 0), (50, -11, 0), (80, -13, 0), (120, -15, 0), (180, -18, 0), (250, -20, 0), (315, -23, 0), (400, -25, 0), (500, -28, 0)],
        # Grade 6
        "g6": [ (3, -8, -2), (6, -12, -4), (10, -14, -5), (18, -17, -6), (30, -20, -7), (50, -25, -9), (80, -29, -10), (120, -34, -12), (180, -40, -14), (250, -46, -15), (315, -52, -17), (400, -57, -18), (500, -63, -20)],
        "h6": [ (3, -6, 0), (6, -8, 0), (10, -9, 0), (18, -11, 0), (30, -13, 0), (50, -16, 0), (80, -19, 0), (120, -22, 0), (180, -25, 0), (250, -29, 0), (315, -32, 0), (400, -36, 0), (500, -40, 0)],
        "js6": [ (3, -3, 3), (6, -4, 4), (10, -4.5, 4.5), (18, -5.5, 5.5), (30, -6.5, 6.5), (50, -8, 8), (80, -9.5, 9.5), (120, -11, 11), (180, -12.5, 12.5), (250, -14.5, 14.5), (315, -16, 16), (400, -18, 18), (500, -20, 20)],
        "k6": [ (3, 0, 6), (6, 1, 9), (10, 1, 10), (18, 1, 12), (30, 2, 15), (50, 2, 18), (80, 2, 21), (120, 3, 25), (180, 4, 28), (250, 4, 33), (315, 4, 36), (400, 5, 40), (500, 5, 45)],
        "m6": [ (3, 2, 8), (6, 4, 12), (10, 6, 15), (18, 7, 18), (30, 8, 21), (50, 9, 25), (80, 10, 30), (120, 13, 35), (180, 15, 40), (250, 17, 46), (315, 20, 52), (400, 23, 57), (500, 25, 63)],
        "n6": [ (3, 4, 10), (6, 8, 16), (10, 10, 19), (18, 12, 23), (30, 15, 28), (50, 17, 33), (80, 20, 39), (120, 23, 45), (180, 27, 52), (250, 31, 60), (315, 34, 66), (400, 40, 73), (500, 45, 80)],
        "p6": [ (3, 6, 12), (6, 12, 20), (10, 15, 24), (18, 18, 29), (30, 22, 35), (50, 26, 42), (80, 32, 51), (120, 37, 59), (180, 43, 68), (250, 50, 79), (315, 56, 88), (400, 62, 98), (500, 68, 108)],
        # Grade 7
        "H7": [ (3, 0, 10), (6, 0, 12), (10, 0, 15), (18, 0, 18), (30, 0, 21), (50, 0, 25), (80, 0, 30), (120, 0, 35), (180, 0, 40), (250, 0, 46), (315, 0, 52), (400, 0, 57), (500, 0, 63)],
        "h7": [ (3, -10, 0), (6, -12, 0), (10, -15, 0), (18, -18, 0), (30, -21, 0), (50, -25, 0), (80, -30, 0), (120, -35, 0), (180, -40, 0), (250, -46, 0), (315, -52, 0), (400, -57, 0), (500, -63, 0)],
        # Grade 8
        "H8": [ (3, 0, 14), (6, 0, 18), (10, 0, 22), (18, 0, 27), (30, 0, 33), (50, 0, 39), (80, 0, 46), (120, 0, 54), (180, 0, 63), (250, 0, 72), (315, 0, 81), (400, 0, 89), (500, 0, 97)],
        "h8": [ (3, -14, 0), (6, -18, 0), (10, -22, 0), (18, -27, 0), (30, -33, 0), (50, -39, 0), (80, -46, 0), (120, -54, 0), (180, -63, 0), (250, -72, 0), (315, -81, 0), (400, -89, 0), (500, -97, 0)],
        # Grade 9
        "H9": [ (3, 0, 25), (6, 0, 30), (10, 0, 36), (18, 0, 43), (30, 0, 52), (50, 0, 62), (80, 0, 74), (120, 0, 87), (180, 0, 100), (250, 0, 115), (315, 0, 130), (400, 0, 140), (500, 0, 155)],
        "d9": [ (3, -45, -20), (6, -60, -30), (10, -76, -40), (18, -93, -50), (30, -117, -65), (50, -142, -80), (80, -174, -100), (120, -207, -120), (180, -245, -145), (250, -285, -170), (315, -320, -190), (400, -350, -210), (500, -385, -230)],
        # Grade 11
        "H11": [ (3, 0, 60), (6, 0, 75), (10, 0, 90), (18, 0, 110), (30, 0, 130), (50, 0, 160), (80, 0, 190), (120, 0, 220), (180, 0, 250), (250, 0, 290), (315, 0, 320), (400, 0, 360), (500, 0, 400)],
        "h11": [ (3, -60, 0), (6, -75, 0), (10, -90, 0), (18, -110, 0), (30, -130, 0), (50, -160, 0), (80, -190, 0), (120, -220, 0), (180, -250, 0), (250, -290, 0), (315, -320, 0), (400, -360, 0), (500, -400, 0)],
        "d11": [ (3, -120, -60), (6, -145, -70), (10, -170, -80), (18, -205, -95), (30, -240, -110), (50, -280, -120), (80, -330, -140), (120, -380, -160), (180, -430, -180), (250, -480, -200), (315, -530, -220), (400, -580, -240), (500, -630, -260)],
        # Grade 12
        "H12": [ (3, 0, 100), (6, 0, 120), (10, 0, 150), (18, 0, 180), (30, 0, 210), (50, 0, 250), (80, 0, 300), (120, 0, 350), (180, 0, 400), (250, 0, 460), (315, 0, 520), (400, 0, 570), (500, 0, 630)],
        "h12": [ (3, -100, 0), (6, -120, 0), (10, -150, 0), (18, -180, 0), (30, -210, 0), (50, -250, 0), (80, -300, 0), (120, -350, 0), (180, -400, 0), (250, -460, 0), (315, -520, 0), (400, -570, 0), (500, -630, 0)],
        # Grade 14
        "H14": [ (3, 0, 250), (6, 0, 300), (10, 0, 360), (18, 0, 430), (30, 0, 520), (50, 0, 620), (80, 0, 740), (120, 0, 870), (180, 0, 1000), (250, 0, 1150), (315, 0, 1300), (400, 0, 1400), (500, 0, 1550)],
        "h14": [ (3, -250, 0), (6, -300, 0), (10, -360, 0), (18, -430, 0), (30, -520, 0), (50, -620, 0), (80, -740, 0), (120, -870, 0), (180, -1000, 0), (250, -1150, 0), (315, -1300, 0), (400, -1400, 0), (500, -1550, 0)],
    }

@st.cache_data
def build_it_tolerance_table(data):
    """Creates a summary table of tolerances by IT grade."""
    it_table = {}
    for field, ranges in data.items():
        match = re.search(r'(\d+)$', field)
        if not match: continue
        qualitet = int(match.group(1))
        if qualitet not in it_table: it_table[qualitet] = {}
        for max_size, l_dev, u_dev in ranges:
            tolerance = abs(u_dev - l_dev)
            if max_size not in it_table[qualitet]: it_table[qualitet][max_size] = tolerance
    final_table = {}
    for qualitet, size_map in it_table.items():
        final_table[qualitet] = sorted(size_map.items())
    return final_table

def identify_qualitet(diameter_mm, user_tolerance_mm, it_data):
    """Finds the best matching and required IT grade for a given tolerance value."""
    user_tolerance_um = user_tolerance_mm * 1000
    if user_tolerance_um <= 0: return {"error_msg": "Tolerance value must be positive."}
    
    best_qualitet, min_error = None, float('inf')
    found_tolerances = {}
    
    for qualitet, ranges in it_data.items():
        standard_tolerance_um = None
        for max_size, tol_val in ranges:
            if diameter_mm <= max_size:
                standard_tolerance_um = tol_val
                break
        if standard_tolerance_um is not None:
            found_tolerances[qualitet] = standard_tolerance_um
            error = abs(user_tolerance_um - standard_tolerance_um)
            if error < min_error:
                min_error, best_qualitet = error, qualitet
    
    if best_qualitet is None: return {"error_msg": "Could not find a suitable grade for the given diameter."}
    
    required_qualitet, max_smaller_tol = None, -1
    for q, tol in found_tolerances.items():
        if tol <= user_tolerance_um and tol > max_smaller_tol:
            max_smaller_tol = tol
            required_qualitet = q
            
    return {
        "best_qualitet": best_qualitet,
        "required_qualitet": required_qualitet,
        "standard_tolerance_um": found_tolerances.get(best_qualitet),
        "user_tolerance_um": user_tolerance_um,
        "all_found": sorted(found_tolerances.items())
    }

def get_tolerance_from_it_grade(diameter_mm, qualitet, it_data):
    """Finds the tolerance value for a given diameter and IT grade."""
    if qualitet not in it_data:
        return None, f"Grade IT{qualitet} not found in the database."
    
    ranges = it_data[qualitet]
    for max_size, tol_val in ranges:
        if diameter_mm <= max_size:
            return tol_val, None # Return tolerance in µm
    
    return None, "Diameter is out of range for the selected grade."


@st.cache_data
def create_qualitet_dataframe(it_table):
    """Creates and formats a DataFrame to display the tolerance table."""
    all_boundaries = sorted(list(set(size for q_ranges in it_table.values() for size, _ in q_ranges)))
    
    index_labels = []
    last_b = 0
    for b in all_boundaries:
        if last_b == 0: index_labels.append(f"up to {b} incl.")
        else: index_labels.append(f"over {last_b} to {b} incl.")
        last_b = b
        
    columns = sorted(it_table.keys())
    col_labels = [f"IT{q}" for q in columns]
    df = pd.DataFrame(index=index_labels, columns=col_labels)

    for q, ranges in it_table.items():
        col_name = f"IT{q}"
        last_b = 0
        for max_size, tol_val in ranges:
            if last_b == 0: row_label = f"up to {max_size} incl."
            else: row_label = f"over {last_b} to {max_size} incl."
            if row_label in df.index: df.loc[row_label, col_name] = tol_val
            last_b = max_size
            
    return df.fillna('-')

# --- UI ---
st.set_page_config(layout="centered", page_title="Tolerance Finder")
st.title("🔍 Tolerance Finder")
st.markdown("Find a standard **Tolerance Grade (IT)** from a value, or find a **Tolerance Value** from a grade, according to **ISO 286**.")

# --- Mode Selection ---
finder_mode = st.radio(
    "Select Mode:",
    ("Find Grade from Tolerance", "Find Tolerance from Grade"),
    horizontal=True
)
st.markdown("---")

# --- Initialize Data ---
tolerance_data = get_tolerance_data()
it_table = build_it_tolerance_table(tolerance_data)
mm_per_inch = 25.4

# --- Common UI elements ---
unit_system = st.radio("Select unit system:", ("Millimeters (mm)", "Inches (in)"), horizontal=True)

is_inch = unit_system == "Inches (in)"
diam_label = "Nominal Diameter (in)" if is_inch else "Nominal Diameter (mm)"
diam_val = 1.0 if is_inch else 25.0

# --- Mode 1: Find Grade from Tolerance ---
if finder_mode == "Find Grade from Tolerance":
    
    tol_label = "Tolerance Value (in)" if is_inch else "Tolerance Value (mm)"
    tol_val = 0.0002 if is_inch else 0.005
    tol_format = "%.5f" if is_inch else "%.4f"
    help_text = "e.g., 0.0005" if is_inch else "e.g., 0.012"

    col1, col2 = st.columns(2)
    with col1:
        diameter_input = st.number_input(diam_label, min_value=0.001, value=diam_val, step=0.1, format="%.3f")
    with col2:
        user_tolerance_input = st.number_input(tol_label, value=tol_val, format=tol_format, help=help_text)

    if st.button("✅ Find Tolerance Grade", use_container_width=True):
        diameter_mm = diameter_input * mm_per_inch if is_inch else diameter_input
        user_tolerance_mm = user_tolerance_input * mm_per_inch if is_inch else user_tolerance_input
        result = identify_qualitet(diameter_mm, user_tolerance_mm, it_table)
        st.markdown("---")
        if "error_msg" in result: st.error(result["error_msg"])
        else:
            best_q, req_q = result['best_qualitet'], result['required_qualitet']
            st_tol_um, user_tol_um = result['standard_tolerance_um'], result['user_tolerance_um']
            st.subheader("Analysis Result")
            st.success(f"Best matching grade: **IT{best_q}**")
            if is_inch:
                st_tol_in = st_tol_um / mm_per_inch / 1000
                metric_value = f"{st_tol_in:.5f} in (or ±{st_tol_in/2:.5f} in)"
                user_tol_in = user_tol_um / mm_per_inch / 1000
                delta_val = user_tol_in - st_tol_in
                delta_unit, delta_format = "in", ".5f"
            else:
                st_tol_mm = st_tol_um / 1000
                metric_value = f"{st_tol_mm:.4f} mm ({st_tol_um:.1f} µm or ±{st_tol_mm/2:.4f} mm)".replace('.', ',')
                delta_val, delta_unit, delta_format = user_tol_um - st_tol_um, "µm", ".1f"
            st.metric(label=f"Standard tolerance for IT{best_q}", value=metric_value, delta=f"{delta_val:{delta_format}} {delta_unit} (deviation from standard)", delta_color="off")
            if req_q is not None and req_q < 6:
                st.warning(f"**Warning!** The required grade **IT{req_q}** is a high-precision grade. Consider using a coarser grade (IT6 or higher) if technologically feasible.")
            st.markdown("#### Comparison with all grades")
            output_str = ""
            for q, tol_um in result['all_found']:
                if is_inch:
                    val_in = tol_um / mm_per_inch / 1000
                    display_str = f"{val_in:.5f} in (or ±{val_in / 2.0:.5f} in)"
                else:
                    val_mm = tol_um / 1000.0
                    symmetrical_mm_str = f"{val_mm / 2.0:.4f}".replace('.', ',')
                    display_str = f"{val_mm:.4f} mm ({tol_um:.1f} µm or ±{symmetrical_mm_str})"
                if q == req_q: output_str += f"**IT{q} → {display_str} (Required for input)**\n\n"
                elif q == best_q: output_str += f"**IT{q} → {display_str} (Closest match)**\n\n"
                else: output_str += f"{display_str}\n\n"
            st.markdown(output_str)

# --- Mode 2: Find Tolerance from Grade ---
elif finder_mode == "Find Tolerance from Grade":
    available_qualites = sorted(it_table.keys())
    col1, col2 = st.columns(2)
    with col1:
        diameter_input = st.number_input(diam_label, min_value=0.001, value=diam_val, step=0.1, format="%.3f")
    with col2:
        selected_qualitet = st.selectbox("Select IT Grade", available_qualites, index=available_qualites.index(7))

    if st.button("✅ Find Tolerance Value", use_container_width=True):
        diameter_mm = diameter_input * mm_per_inch if is_inch else diameter_input
        tolerance_um, error = get_tolerance_from_it_grade(diameter_mm, selected_qualitet, it_table)
        st.markdown("---")
        if error:
            st.error(error)
        else:
            tolerance_mm = tolerance_um / 1000.0
            tolerance_in = tolerance_um / mm_per_inch / 1000.0
            st.subheader("Analysis Result")
            st.success(f"Standard tolerance for **IT{selected_qualitet}** at a diameter of **{diameter_input} {unit_system.split(' ')[1]}** is:")
            
            if is_inch:
                main_value = f"{tolerance_in:.5f} in (or ±{tolerance_in/2.0:.5f} in)"
                secondary_value = f"Equivalent: {tolerance_mm:.4f} mm"
            else:
                main_value = f"{tolerance_mm:.4f} mm ({tolerance_um:.1f} µm or ±{tolerance_mm/2.0:.4f} mm)".replace('.', ',')
                secondary_value = f"Equivalent: {tolerance_in:.5f} in"
            
            st.metric(label="Calculated Tolerance", value=main_value)
            st.info(secondary_value)

# --- Common Reference Table ---
st.markdown("---")
expander_label = "Show Standard Tolerances Table (in)" if is_inch else "Show Standard Tolerances Table (mm)"
with st.expander(expander_label):
    df_qualitets_metric = create_qualitet_dataframe(it_table)
    if is_inch:
        df_to_display = df_qualitets_metric.copy()
        def convert_to_inches(val_str):
            if val_str == '-': return '-'
            try: return f"{float(val_str) / mm_per_inch / 1000:.5f}"
            except (ValueError, TypeError): return '-'
        df_to_display = df_to_display.applymap(convert_to_inches)
        new_inch_index = []
        for label in df_qualitets_metric.index:
            numbers = [float(n) for n in re.findall(r'(\d+\.?\d*)', label)]
            if len(numbers) == 1: new_label = f"up to {numbers[0] / mm_per_inch:.4f} incl."
            elif len(numbers) == 2: new_label = f"over {numbers[0] / mm_per_inch:.4f} to {numbers[1] / mm_per_inch:.4f} incl."
            else: new_label = label
            new_inch_index.append(new_label)
        df_to_display.index = new_inch_index
    else: # Millimeter mode
        df_to_display = df_qualitets_metric.copy()
        def convert_to_mm(val_str):
            if val_str == '-': return '-'
            try: return f"{float(val_str) / 1000.0:.4f}"
            except (ValueError, TypeError): return '-'
        df_to_display = df_to_display.applymap(convert_to_mm)
        
    st.dataframe(df_to_display, use_container_width=True)
