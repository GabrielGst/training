import fs from 'fs';
import path from 'path';
import { ProgressData, TrackSummary } from '@/types';

const DATA_FILE = path.join(process.cwd(), 'data', 'progress.json');

const DEFAULT_DATA: ProgressData = {
  tracks: [
    {
      id: 'ai-engineer',
      name: 'AI Engineer',
      modules: [
        { id: '01-python-foundations', name: 'Python Foundations', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '02-fastapi', name: 'FastAPI', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '03-data-viz-seaborn-plotly', name: 'Data Viz — Seaborn + Plotly', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '04-tensorflow', name: 'TensorFlow', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '05-pytorch', name: 'PyTorch', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '06-capstone-ml-api', name: 'Capstone: ML Model API', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
      ],
    },
    {
      id: 'software-engineer',
      name: 'Software Engineer',
      modules: [
        { id: '01-shell-scripting', name: 'Shell Scripting', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '02-nodejs-fundamentals', name: 'Node.js Fundamentals', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '03-nextjs', name: 'Next.js', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '04-orchestration', name: 'Orchestration', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '05-capstone-fullstack-app', name: 'Capstone: Full-Stack App', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
      ],
    },
    {
      id: 'data-engineer',
      name: 'Data Engineer',
      modules: [
        { id: '01-postgresql', name: 'PostgreSQL', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '02-django-orm', name: 'Django ORM', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '03-mysql-mariadb', name: 'MySQL / MariaDB', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '04-data-pipelines', name: 'Data Pipelines (Airflow + dbt)', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '05-capstone-data-platform', name: 'Capstone: Data Platform', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
      ],
    },
    {
      id: 'ai-agents',
      name: 'AI Agents',
      modules: [
        { id: '01-llm-fundamentals', name: 'LLM Fundamentals', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '02-langchain', name: 'LangChain', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '03-langgraph', name: 'LangGraph', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '04-crewai', name: 'CrewAI', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '05-mcp-tool-use', name: 'MCP Tool Use', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '06-capstone-agent-system', name: 'Capstone: Agent System', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
      ],
    },
    {
      id: 'gpu-monitoring',
      name: 'GPU Monitoring',
      modules: [
        { id: '01-cuda-setup', name: 'CUDA Setup', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '02-nvidia-smi-nvtop', name: 'nvidia-smi + nvtop', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '03-remote-training-bridge', name: 'Remote Training Bridge', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
      ],
    },
    {
      id: 'hpc-quantum',
      name: 'HPC & Quantum',
      modules: [
        { id: '01-hpc-intro', name: 'HPC Intro (Slurm + MPI)', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
        { id: '02-quantum-intro', name: 'Quantum Intro (Qiskit)', status: 'not_started', hoursLogged: 0, lastUpdated: null, notes: '' },
      ],
    },
  ],
  dailyLog: [],
  streak: { current: 0, longest: 0, lastStudyDate: null },
};

export function readProgress(): ProgressData {
  try {
    if (fs.existsSync(DATA_FILE)) {
      return JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8')) as ProgressData;
    }
  } catch {
    // fall through to defaults
  }
  return structuredClone(DEFAULT_DATA);
}

export function writeProgress(data: ProgressData): void {
  const dir = path.dirname(DATA_FILE);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf-8');
}

export function getTrackSummaries(): TrackSummary[] {
  const { tracks } = readProgress();
  return tracks.map((track) => {
    const completed = track.modules.filter((m) => m.status === 'completed').length;
    const inProgress = track.modules.filter((m) => m.status === 'in_progress').length;
    const totalHours = track.modules.reduce((sum, m) => sum + m.hoursLogged, 0);
    const progressPercent =
      track.modules.length === 0
        ? 0
        : Math.round((completed / track.modules.length) * 100);
    return {
      id: track.id,
      name: track.name,
      totalModules: track.modules.length,
      completedModules: completed,
      inProgressModules: inProgress,
      totalHours,
      progressPercent,
    };
  });
}

export function getGlobalProgress() {
  const { tracks } = readProgress();
  const allModules = tracks.flatMap((t) => t.modules);
  const completedModules = allModules.filter((m) => m.status === 'completed').length;
  const totalModules = allModules.length;
  const totalHours = allModules.reduce((sum, m) => sum + m.hoursLogged, 0);
  const progressPercent =
    totalModules === 0 ? 0 : Math.round((completedModules / totalModules) * 100);
  return { completedModules, totalModules, totalHours, progressPercent };
}
