-- Up Migration
INSERT INTO services (code, code_type, description, category) VALUES
  ('70450', 'CPT', 'CT head/brain without contrast', 'imaging'),
  ('80053', 'CPT', 'Comprehensive metabolic panel', 'lab'),
  ('70551', 'CPT', 'MRI brain without contrast', 'imaging'),
  ('73721', 'CPT', 'MRI knee (lower-extremity joint) without contrast', 'imaging'),
  ('74177', 'CPT', 'CT abdomen and pelvis with contrast', 'imaging'),
  ('76700', 'CPT', 'Ultrasound, abdomen complete', 'imaging'),
  ('80048', 'CPT', 'Basic metabolic panel', 'lab'),
  ('85025', 'CPT', 'Complete blood count (CBC) with differential', 'lab'),
  ('80061', 'CPT', 'Lipid panel', 'lab'),
  ('83036', 'CPT', 'Hemoglobin A1c', 'lab'),
  ('99203', 'CPT', 'Office visit, new patient (low complexity)', 'visit'),
  ('99213', 'CPT', 'Office visit, established patient (low complexity)', 'visit'),
  ('99283', 'CPT', 'Emergency department visit, moderate', 'visit'),
  ('99285', 'CPT', 'Emergency department visit, high', 'visit'),
  ('45378', 'CPT', 'Colonoscopy, diagnostic', 'procedure'),
  ('66984', 'CPT', 'Cataract removal with lens implant', 'procedure'),
  ('29881', 'CPT', 'Knee arthroscopy with meniscectomy', 'procedure'),
  ('470',   'MS-DRG', 'Major hip or knee joint replacement without MCC', 'procedure'),
  ('807',   'MS-DRG', 'Vaginal delivery without sterilization/D&C, without CC/MCC', 'procedure'),
  ('788',   'MS-DRG', 'Cesarean section without sterilization, without CC/MCC', 'procedure')

-- Down Migration
DELETE FROM services WHERE (code, code_type) IN (
  ('70450','CPT'), ('80053', 'CPT'), ('70551', 'CPT'), ('73721', 'CPT'), ('74177', 'CPT'), ('76700', 'CPT'), ('80048', 'CPT'), ('85025', 'CPT'), ('80061', 'CPT'), ('83036', 'CPT'), ('99203', 'CPT'), ('99213', 'CPT'), ('99283', 'CPT'), ('99285', 'CPT'), ('45378', 'CPT'), ('66984', 'CPT'), ('29881', 'CPT'), ('470', 'MS-DRG'), ('807', 'MS-DRG'), ('788', 'MS-DRG')
);