# ==========================================
# STAGE 1: Build Frontend (Vite)
# ==========================================
FROM node:20-alpine AS frontend-builder
WORKDIR /app

# Chỉ copy thư mục frontend-demo
COPY frontend-demo/ ./frontend-demo/

# Cài đặt dependency và build
WORKDIR /app/frontend-demo
RUN npm install
RUN npm run build

# ==========================================
# STAGE 2: Production Run (Python + FastAPI)
# ==========================================
FROM python:3.11-slim
WORKDIR /app

# Cài đặt công cụ uv để tăng tốc độ cài package Python
RUN pip install uv

# Copy các file cấu hình Python
COPY pyproject.toml uv.lock ./

# Copy toàn bộ mã nguồn của các Agents
COPY common/ ./common/
COPY registry/ ./registry/
COPY customer_agent/ ./customer_agent/
COPY law_agent/ ./law_agent/
COPY tax_agent/ ./tax_agent/
COPY compliance_agent/ ./compliance_agent/

# Copy các file khởi chạy
COPY serve_render.py ./
COPY start_render.sh ./

# Cấp quyền thực thi cho script bash
RUN chmod +x start_render.sh

# Cài đặt toàn bộ Python dependencies bằng uv (dựa vào pyproject.toml)
RUN uv pip install --system -r pyproject.toml

# Copy thành phẩm Frontend (đã build) từ Stage 1 sang Stage 2
# Đặt vào đúng thư mục mà serve_render.py đang tìm kiếm
COPY --from=frontend-builder /app/frontend-demo/dist ./frontend-demo/dist

# Render sẽ tự động gán biến môi trường PORT, ta có thể EXPOSE hờ
EXPOSE 8080

# Chạy toàn bộ hệ thống (5 Agents + Proxy)
CMD ["./start_render.sh"]
