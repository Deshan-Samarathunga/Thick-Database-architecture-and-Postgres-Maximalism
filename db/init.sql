-- Create anonymous web role for PostgREST
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA public TO web_anon;

-- Create tasks table
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT, INSERT, UPDATE, DELETE ON tasks TO web_anon;
GRANT USAGE, SELECT ON SEQUENCE tasks_id_seq TO web_anon;

-- Insert some dummy data
INSERT INTO tasks (title) VALUES ('Learn PostgreSQL'), ('Master HTMX'), ('Replace Node.js');

-- Function to render a single task as HTML
CREATE OR REPLACE FUNCTION render_task(task_row tasks) RETURNS text AS $$
BEGIN
    RETURN format(
        '<div class="task %s" id="task-%s">
            <span style="text-decoration: %s">%s</span>
            <button hx-post="/rpc/toggle_task" hx-ext="json-enc" hx-vals=''{"p_id": %s}'' hx-target="#task-list">
                Toggle
            </button>
        </div>',
        CASE WHEN task_row.is_completed THEN 'completed' ELSE 'pending' END,
        task_row.id,
        CASE WHEN task_row.is_completed THEN 'line-through' ELSE 'none' END,
        task_row.title,
        task_row.id
    );
END;
$$ LANGUAGE plpgsql;

-- Function to render the entire task list
CREATE OR REPLACE FUNCTION render_task_list() RETURNS text AS $$
DECLARE
    result text := '';
    task_rec tasks;
BEGIN
    FOR task_rec IN SELECT * FROM tasks ORDER BY created_at DESC LOOP
        result := result || render_task(task_rec);
    END LOOP;
    
    IF result = '' THEN
        result := '<p>No tasks found.</p>';
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to add a task and return the updated list
CREATE OR REPLACE FUNCTION add_task(p_title text) RETURNS text AS $$
BEGIN
    IF trim(p_title) != '' THEN
        INSERT INTO tasks (title) VALUES (trim(p_title));
    END IF;
    RETURN render_task_list();
END;
$$ LANGUAGE plpgsql;

-- Function to toggle a task and return the updated list
CREATE OR REPLACE FUNCTION toggle_task(p_id int) RETURNS text AS $$
BEGIN
    UPDATE tasks SET is_completed = NOT is_completed WHERE id = p_id;
    RETURN render_task_list();
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION render_task_list() TO web_anon;
GRANT EXECUTE ON FUNCTION add_task(text) TO web_anon;
GRANT EXECUTE ON FUNCTION toggle_task(int) TO web_anon;
