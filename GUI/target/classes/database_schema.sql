

-- Create "SystemAdmin" table
CREATE TABLE system_admin (
    id character varying PRIMARY KEY,
    password character varying,
    action_history character varying[]
);

-- Create (parent) provider table
CREATE TABLE provider (
    p_id character varying PRIMARY KEY,
    role character varying,
    full_name character varying,
    password character varying,
    action_history character varying[]
);

-- Create (children) "InsuranceSurveyor" table
CREATE TABLE insurance_surveyor (
    insurance_manager character varying
)
    INHERITS (provider);

-- Create (children) insurance_manager table
CREATE TABLE insurance_manager (
    surveyor_list character varying[]
)
    INHERITS (provider);

-- Create insurance_card  table
CREATE TABLE insurance_card (
    card_number character varying PRIMARY KEY,
    card_holder character varying,
    policy_owner character varying,
    expiration_date date
);

-- Create document table
CREATE TABLE document (
    document_id character varying PRIMARY KEY,
    f_id character varying,
    file_name character varying,
    convert_file_name character varying,
    url character varying
);

-- Create claim table
CREATE TABLE claim(
    f_id character varying PRIMARY KEY,
    claim_date date,
    insured_person character varying,
    card_number character varying,
    exam_date date,
    document_list character varying[],
    claim_amount numeric,
    status character varying,
    receiver_banking_info character varying,
    note character varying
);

-- Create (parent)customer table
CREATE TABLE customer(
   c_id character varying PRIMARY KEY,
   role character varying,
   full_name character varying,
   phone character varying,
   address character varying,
   email character varying,
   password character varying,
   action_history character varying[],
   claim_list character varying[]
);

-- Create (child) policy_owner  table
CREATE TABLE policy_owner (
    beneficiaries character varying[],
    insurance_fee numeric
)
    INHERITS (customer);

-- Create (child) policy_holder  table
CREATE TABLE policy_holder (
   policy_owner  character varying,
   insurance_card_number character varying,
   dependentList character varying[]
)
    INHERITS (customer);

-- Create (child) dependent  table
CREATE TABLE dependent (
   policy_owner  character varying,
   policy_holder  character varying,
   insurance_card_number character varying
)
    INHERITS (customer);

-- Alter claim table (card_number) to REFERENCE insurance_card  (card_number)
ALTER TABLE claim
    ADD FOREIGN KEY (card_number) REFERENCES insurance_card (card_number);

-- Alter claim table (insured_person) to REFERENCE customer (c_id)
ALTER TABLE claim
    ADD FOREIGN KEY (insured_person) REFERENCES customer(c_id);

-- Alter document table (f_id) to REFERENCE claim (f_id)
ALTER TABLE document
    ADD FOREIGN KEY (f_id) REFERENCES claim(f_id);

-- Create a function to check p_id uniqueness only for INSERT operations
CREATE OR REPLACE FUNCTION enforce_unique_pid() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM provider WHERE p_id = NEW.p_id) THEN
        RAISE EXCEPTION 'p_id % already exists.', NEW.p_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach the trigger to insurance_manager for INSERT operations only
CREATE TRIGGER check_unique_pid_insurance_manager
    BEFORE INSERT ON insurance_manager
    FOR EACH ROW EXECUTE FUNCTION enforce_unique_pid();

-- Attach the trigger to insurance_surveyor for INSERT operations only
CREATE TRIGGER check_unique_pid_insurance_surveyor
    BEFORE INSERT ON insurance_surveyor
    FOR EACH ROW EXECUTE FUNCTION enforce_unique_pid();

-- Create a function to check c_id uniqueness only for INSERT operations
CREATE OR REPLACE FUNCTION enforce_unique_cid() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM customer WHERE c_id = NEW.c_id) THEN
        RAISE EXCEPTION 'c_id % already exists.', NEW.c_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach the trigger to policy_owner for INSERT operations only
CREATE TRIGGER check_unique_cid_policy_owner
    BEFORE INSERT ON policy_owner
    FOR EACH ROW EXECUTE FUNCTION enforce_unique_cid();

-- Attach the trigger to policy_holder for INSERT operations only
CREATE TRIGGER check_unique_cid_policy_holder
    BEFORE INSERT ON policy_holder
    FOR EACH ROW EXECUTE FUNCTION enforce_unique_cid();

-- Attach the trigger to dependent for INSERT operations only
CREATE TRIGGER check_unique_cid_dependent
    BEFORE INSERT ON dependent
    FOR EACH ROW EXECUTE FUNCTION enforce_unique_cid();
